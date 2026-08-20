import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_alert_archive.dart';
import 'package:foss_warn/class/class_app_state.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/class/class_notification_preferences.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/enums/notification_channel.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/enums/sorting_categories.dart';
import 'package:foss_warn/extensions/list.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/services/api_handler.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/constants.dart' as constants;

import '../class/class_error_logger.dart';

class AlertRetrievalError implements Exception {}

/// The alerts we know about.
///
/// This is the single source of truth: it is seeded from disk, persisted on
/// every change and holds the state the user and the app change over time
/// (`read` and `notified`). Everything that modifies an alert goes through the
/// notifier of this provider.
///
/// Anything derived from the alerts - the update relations and the sorting -
/// belongs in [alertsProvider], which is what the views render.
final processedAlertsProvider =
    StateNotifierProvider<WarningService, List<WarnMessage>>(
  WarningService.new,
);

/// Fetches alerts for all subscriptions and reconciles them with the store.
///
/// Any new alerts will be fetched completely, any we already know about
/// will be retrieved from cache instead. The result of the fetch lands in
/// [processedAlertsProvider]; this provider returns nothing and only exists so
/// the UI can watch its [AsyncValue] for the loading and error state.
final alertsFutureProvider = FutureProvider<void>((ref) async {
  var alertApi = ref.read(alertApiProvider);
  List<Place> places = [];
  places = ref.read(myPlacesProvider);
  if (places.isEmpty) {
    // make sure that we can wait until we get some places back
    // as fallback and for the background process
    places = await ref.read(cachedPlacesProvider.future);
  }

  if (places.isEmpty) {
    // nothing to fetch, so nothing can be out of date either
    ref.read(appStateProvider.notifier).setAreWarningsFromCache(false);
    return;
  }

  // Fetch all available alerts
  List<AlertApiResult> retrievedAlerts;

  /// fetch alerts for one place and catch invalid subscriptions errors
  Future<List<AlertApiResult>> getAlertForOnePlace(
    Place place,
    AppState appState,
  ) async {
    if (place.isExpired) {
      // the places has expired, We can not fetch for alerts until we resubscribed again
      return [];
    }

    try {
      return await alertApi.getAlerts(
        place: place,
        appState: appState,
      );
    } on InvalidSubscriptionError {
      // set expired to true
      ref
          .read(myPlacesProvider.notifier)
          .set(places.updateEntry(place.copyWith(isExpired: true)));
      return [];
    }
  }

  try {
    List<List<({String alertId, String placeId})>> alertsForPlaces =
        await Future.wait([
      for (var place in places) ...[
        getAlertForOnePlace(place, ref.read(appStateProvider)),
      ],
    ]);

    // Combine alerts for the individual places into a single list
    retrievedAlerts =
        alertsForPlaces.reduce((value, element) => value + element);
  } catch (e) {
    debugPrint("[warnings] Tried to get alerts forPlaces and failed with $e");
    ref.read(appStateProvider.notifier).setAreWarningsFromCache(true);
    throw AlertRetrievalError();
  }

  var previouslyCachedAlerts = ref.read(processedAlertsProvider);

  // Determine which alerts we don't already know about
  var newAlerts = <AlertApiResult>[];
  for (AlertApiResult alert in retrievedAlerts) {
    if (!previouslyCachedAlerts.any(
      (oldAlert) =>
          oldAlert.fpasId == alert.alertId && oldAlert.placeId == alert.placeId,
    )) {
      newAlerts.add(alert);
    }
  }

  // Only get detail for new results
  // fetch all alerts in parallel and skip failed alerts
  final List<WarnMessage> newAlertsDetails = (await Future.wait(
    newAlerts.map((alert) async {
      try {
        return await alertApi.getAlertDetail(
          alertId: alert.alertId,
          placeId: alert.placeId,
        );
      } catch (e) {
        ErrorLogger.writeLog(
          "warnings.dart",
          "Get alert detail (${alert.alertId}) failed",
          e.toString(),
        );

        return null;
      }
    }),
  ))
      .whereType<WarnMessage>()
      .toList();

  // report a failed detail fetch, but do not keep the error around once a
  // later cycle went through cleanly
  ref
      .read(appStateProvider.notifier)
      .setError(newAlertsDetails.length != newAlerts.length);

  // add new alert to the processed alerts
  for (WarnMessage alert in newAlertsDetails) {
    ref.read(processedAlertsProvider.notifier).updateAlert(alert);
    if (ref.read(userPreferencesProvider).alertArchive) {
      AlertArchive.writeAlertToArchive(alert);
    }
  }

  var cachedAlerts = ref.read(processedAlertsProvider);
  for (WarnMessage alert in cachedAlerts) {
    if (!retrievedAlerts.any(
          (apiResult) =>
              alert.fpasId == apiResult.alertId &&
              alert.placeId == apiResult.placeId,
        ) &&
        alert.placeId != constants.noPlaceId) {
      // the alert is not in the server response anymore, remove cached alert
      ref.read(processedAlertsProvider.notifier).deleteAlert(alert);
    }
  }

  // we have once fetched alerts, we do not need to display the loading scree again.
  var appStateService = ref.read(appStateProvider.notifier);
  appStateService.setIsFirstFetch(false);
  // reset no internet flag
  ref.read(appStateProvider.notifier).setAreWarningsFromCache(false);
});

final alertPollingProvider = StreamProvider.autoDispose(
  (ref) => Stream.periodic(const Duration(seconds: 5)),
);

/// Provides the complete list of alerts for subscribed places, ready to be
/// displayed: the update relations are applied and the list is sorted
/// according to the user preference.
///
/// This is what the views render. Modifying an alert still goes through
/// [processedAlertsProvider], and the derived flags are recomputed from there.
final alertsProvider = Provider<List<WarnMessage>>((ref) {
  ref.listen(alertPollingProvider, (_, __) {
    ref.invalidate(alertsFutureProvider);
  });
  // @TODO pause polling if app is in background

  // keep the fetch alive - its AsyncValue drives the connection error widget
  ref.watch(alertsFutureProvider);

  var alerts = ref.watch(processedAlertsProvider);
  var sortWarningsBy = ref.watch(
    userPreferencesProvider.select((preferences) => preferences.sortWarningsBy),
  );

  return sortAlerts(applyUpdateRelations(alerts), sortWarningsBy);
});

/// The severity an alert is sorted and compared by.
///
/// An alert without an info block cannot state a severity, so it is treated
/// like an alert of unknown severity instead of crashing the whole list.
Severity _severityOf(WarnMessage alert) =>
    alert.info.isEmpty ? Severity.unknown : alert.info.first.severity;

/// Apply the relations between an alert and the alerts it references.
///
/// Sets, for every alert:
///   - [WarnMessage.hideWarningBecauseThereIsANewerVersion] when another alert
///     in [alerts] references it, so only the newest version is listed and the
///     older ones stay reachable through the update thread.
///   - [WarnMessage.isUpdateOfAlreadyNotifiedWarning] when the alert updates an
///     alert we already notified about and did not become more severe. Those
///     are shown on the quiet update channel instead of alerting again.
///
/// Both flags are always written, so an alert stops being hidden as soon as the
/// alert that superseded it is gone.
List<WarnMessage> applyUpdateRelations(List<WarnMessage> alerts) {
  // The identifier should be unique, but in reality it isn't, so keep the
  // first alert we saw for an identifier.
  final Map<String, WarnMessage> alertsByIdentifier = {};
  for (final alert in alerts) {
    alertsByIdentifier.putIfAbsent(alert.identifier, () => alert);
  }

  // every identifier that another alert refers to has a newer version
  final Set<String> supersededIdentifiers = {};
  for (final alert in alerts) {
    final references = alert.references;
    if (references == null) continue;
    for (final identifier in references.identifier) {
      if (alertsByIdentifier.containsKey(identifier)) {
        supersededIdentifiers.add(identifier);
      }
    }
  }

  return [
    for (final alert in alerts)
      alert.copyWith(
        isUpdateOfAlreadyNotifiedWarning:
            _isUpdateOfNotifiedAlert(alert, alertsByIdentifier),
        hideWarningBecauseThereIsANewerVersion:
            supersededIdentifiers.contains(alert.identifier),
      ),
  ];
}

/// Returns the notified state of the alert [alert] updates, as long as the
/// alert did not become more severe. A severity increase has to alert the user
/// again, even if the previous version was already notified.
bool _isUpdateOfNotifiedAlert(
  WarnMessage alert,
  Map<String, WarnMessage> alertsByIdentifier,
) {
  final references = alert.references;
  if (references == null) return false;

  for (final identifier in references.identifier) {
    final referenced = alertsByIdentifier[identifier];
    if (referenced == null) continue;

    // a low index means a high danger, so ">=" means "not more severe"
    if (_severityOf(alert).index >= _severityOf(referenced).index) {
      return referenced.notified;
    }
  }
  return false;
}

/// Sort [alerts] by the given user preference. Returns a new list.
List<WarnMessage> sortAlerts(
  List<WarnMessage> alerts,
  SortingCategories sortWarningsBy,
) {
  var sortedWarnings = List<WarnMessage>.of(alerts);

  switch (sortWarningsBy) {
    case SortingCategories.severity:
      sortedWarnings.sort(
        (a, b) => Severity.getIndexFromSeverity(_severityOf(a))
            .compareTo(Severity.getIndexFromSeverity(_severityOf(b))),
      );
    case SortingCategories.data:
      sortedWarnings.sort((a, b) => b.sent.compareTo(a.sent));
    case SortingCategories.source:
      sortedWarnings.sort((a, b) => b.sender.compareTo(a.sender));
  }

  return sortedWarnings;
}

/// set the read status from all warnings to true
/// @ref to update view
void markAllWarningsAsRead(WidgetRef ref) {
  var alerts = ref.read(processedAlertsProvider);

  for (var alert in alerts) {
    ref
        .read(processedAlertsProvider.notifier)
        .updateAlert(alert.copyWith(read: true));
  }
}

/// show notifications for alerts
Future<void> showNotification(
  List<WarnMessage> alerts,
  List<Place> places,
  UserPreferences userPreferences,
  WarningService alertService,
) async {
  for (WarnMessage warning in alerts) {
    String placeName = "";
    Place? place = places.firstWhereOrNull(
      (place) => place.id == warning.placeId,
    );

    if (place != null) {
      placeName = place.name;
    }

    if (warning.info.isEmpty) {
      await ErrorLogger.writeLog(
        "warnings.dart",
        "showNotification",
        "Alert ${warning.fpasId} has no info block and is not notified",
      );
      continue;
    }

    if (NotificationPreferences.checkIfEventShouldBeNotified(
          warning.info[0].severity,
          warning.info[0].category,
          userPreferences,
        ) &&
        !warning.read &&
        !warning.notified) {
      if (!warning.isUpdateOfAlreadyNotifiedWarning) {
        // show notification with sound
        await NotificationService.showNotification(
          id: warning.fpasId.hashCode,
          title: "$placeName: ${warning.info[0].headline}",
          body: warning.info[0].description
              .substring(0, min(150, warning.info[0].description.length)),
          payload: placeName,
          channel:
              NotificationChannel.fromSeverity(warning.info.first.severity),
        );
      } else {
        await NotificationService.showNotification(
          // show notification as update only -> less distributive
          id: warning.fpasId.hashCode,
          title: "$placeName: ${warning.info[0].headline}",
          body: warning.info[0].headline,
          payload: placeName,
          channel: NotificationChannel.update,
        );
      }
      alertService.updateAlert(warning.copyWith(notified: true));
    }
  }
}

/// Holds the alerts and persists them.
///
/// The service reads the user preferences through [Ref] instead of watching
/// them: writing an alert stores the list in the preferences, and watching them
/// here would dispose and recreate this notifier on its own write.
class WarningService extends StateNotifier<List<WarnMessage>> {
  WarningService(Ref ref)
      : _ref = ref,
        super(ref.read(userPreferencesProvider).cachedAlerts);

  final Ref _ref;

  Future<void> _saveAlertsToDisk() async {
    await _ref.read(userPreferencesProvider.notifier).setCachedAlerts(state);
  }

  bool hasWarningToNotify() {
    var userPreferences = _ref.read(userPreferencesProvider);

    return applyUpdateRelations(state).any(
      (alert) =>
          !alert.notified &&
          !alert.hideWarningBecauseThereIsANewerVersion &&
          alert.info.isNotEmpty &&
          NotificationPreferences.checkIfEventShouldBeNotified(
            alert.info[0].severity,
            alert.info[0].category,
            userPreferences,
          ),
    );
  }

  /// Updates the given alert or add the alert if not in the list of alerts
  void updateAlert(WarnMessage alert) {
    var alerts = List<WarnMessage>.from(state);

    if (alerts.contains(alert)) {
      // do not forget to use the return value as new state
      alerts = alerts.updateEntry(alert);
    } else {
      // New from polling
      alerts.add(alert);
    }
    state = alerts;
    _saveAlertsToDisk();
  }

  /// Allows to delete a list of alerts at once
  void deleteMultipleAlerts(List<WarnMessage> alertsToDelete) {
    var alerts = List<WarnMessage>.from(state);

    for (WarnMessage alert in alertsToDelete) {
      if (alerts.contains(alert)) {
        alerts.remove(alert);
      }
    }
    state = alerts;
    _saveAlertsToDisk();
  }

  void deleteAlert(WarnMessage alert) {
    var alerts = List<WarnMessage>.from(state);

    if (alerts.contains(alert)) {
      alerts.remove(alert);
      state = alerts;
    }
    _saveAlertsToDisk();
  }

  /// remove every alert from the list and from the disk cache
  void deleteAllAlerts() {
    state = [];
    _saveAlertsToDisk();
  }

  /// set the read and notified status from all warnings to false
  /// used for debug purpose
  void resetReadAndNotificationStatusForAllWarnings() {
    state = [
      for (var alert in state) ...[
        alert.copyWith(
          read: false,
          notified: false,
        ),
      ],
    ];
    _saveAlertsToDisk();
  }
}
