import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/enums/sorting_categories.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/services/api_handler.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/update_loop.dart';

class AlertRetrievalError implements Exception {}

// TODO(PureTryOut): cache retrieved alerts on disk rather than just in memory
final processedAlertsProvider =
    StateNotifierProvider<WarningService, List<WarnMessage>>(
  (ref) {
    return WarningService(
      userPreferences: ref.watch(userPreferencesProvider),
      places: ref.watch(myPlacesProvider),
    );
  },
);

/// Fetches alerts for all subscriptions.
/// Any new alerts will be fetched completely, any we already know about
/// will be retrieved from cache instead.
final alertsFutureProvider = FutureProvider<List<WarnMessage>>((ref) async {
  var alertApi = ref.watch(alertApiProvider);
  var places = ref.watch(myPlacesProvider);

  if (places.isEmpty) return [];

  // Fetch all available alerts
  List<AlertApiResult> retrievedAlerts;
  try {
    var alertsForPlaces = await Future.wait([
      for (var place in places) ...[
        alertApi.getAlerts(subscriptionId: place.subscriptionId),
      ],
    ]);
    // Combine alerts for the individual places into a single list
    retrievedAlerts =
        alertsForPlaces.reduce((value, element) => value + element);
  } on Exception {
    throw AlertRetrievalError();
  }

  var previouslyCachedAlerts = ref.read(processedAlertsProvider);
  if (retrievedAlerts.isEmpty) {
    return previouslyCachedAlerts;
  }

  // Determine which alerts we don't already know about
  var newAlerts = <AlertApiResult>[];
  for (var alert in retrievedAlerts) {
    if (!previouslyCachedAlerts
        .any((oldAlert) => oldAlert.fpasId == alert.alertId)) {
      newAlerts.add(alert);
    }
  }

  // Only get detail for new results
  var newAlertsDetails = await Future.wait([
    for (var alert in newAlerts) ...[
      alertApi.getAlertDetail(
        alertId: alert.alertId,
        placeSubscriptionId: alert.subscriptionId,
      ),
    ],
  ]);

  return newAlertsDetails + previouslyCachedAlerts;
});

/// Provides a complete list of all warnings for subscribed places.
///
/// It polls for new alerts and merges the result with any locally processed/modified alerts.
/// Any processing off alerts has to be done through [processedAlertsProvider].
final alertsProvider = Provider<List<WarnMessage>>((ref) {
  ref.listen(tickingChangeProvider(50), (_, event) {
    ref.invalidate(alertsFutureProvider);
  });

  var userPreferences = ref.watch(userPreferencesProvider);

  var alertsSnapshot = ref.watch(alertsFutureProvider);

  if (!alertsSnapshot.hasValue) return [];
  var alerts = alertsSnapshot.requireValue;

  List<WarnMessage> sortWarnings(List<WarnMessage> warnings) {
    var sortedWarnings = List<WarnMessage>.of(warnings);

    if (userPreferences.sortWarningsBy == SortingCategories.severity) {
      sortedWarnings.sort(
        (a, b) => Severity.getIndexFromSeverity(a.info[0].severity)
            .compareTo(Severity.getIndexFromSeverity(b.info[0].severity)),
      );
    } else if (userPreferences.sortWarningsBy == SortingCategories.data) {
      sortedWarnings.sort((a, b) => b.sent.compareTo(a.sent));
    }

    return sortedWarnings;
  }

  /// Check if the given alert is an update of a previous alert.
  /// Returns the notified status of the original alert if the severity hasn't increased
  bool isAlertAnUpdate({
    required List<WarnMessage> existingWarnings,
    required WarnMessage newWarning,
  }) {
    // check if there is a referenced warning
    if (newWarning.references != null) {
      // check if one of the referenced alerts is already in the warnings list
      for (var warning in existingWarnings) {
        if (newWarning.references!.identifier
            .any((identifier) => warning.identifier == identifier)) {
          // if there is a referenced alert, used the same value for notified.
          // use the notified value of the referenced warning, but only if the severity is still the same or lesser
          if (newWarning.info[0].severity.index >=
              warning.info[0].severity.index) {
            return warning.notified;
          }
        }
      }
    }
    return false;
  }

  // Determine which alert is an update of a previous one
  var updatedWarnings = <WarnMessage>[];
  for (var alert in alerts) {
    updatedWarnings.add(
      alert.copyWith(
        isUpdateOfAlreadyNotifiedWarning: isAlertAnUpdate(
          existingWarnings: alerts,
          newWarning: alert,
        ),
      ),
    );
  }
  for (var warning in updatedWarnings) {
    if (warning.references == null) continue;

    // The alert contains a reference, so it is an update of an previous alert
    for (var referenceId in warning.references!.identifier) {
      // Check all alerts for references
      var alWm = alerts.firstWhere((alert) => alert.identifier == referenceId);
      alerts.updateEntry(
        alWm.copyWith(hideWarningBecauseThereIsANewerVersion: true),
      );
    }
  }

  return sortWarnings(alerts);
});

/// set the read status from all warnings to true
/// @ref to update view
void markAllWarningsAsRead(WidgetRef ref) {
  var alerts = ref.read(alertsProvider);

  for (var alert in alerts) {
    ref
        .read(processedAlertsProvider.notifier)
        .updateAlert(alert.copyWith(read: true));
  }
}

class WarningService extends StateNotifier<List<WarnMessage>> {
  WarningService({required this.userPreferences, required this.places})
      : super(<WarnMessage>[]);

  final UserPreferences userPreferences;
  final List<Place> places;

  bool hasWarningToNotify() =>
      state.isNotEmpty &&
      state.any(
        (element) =>
            !element.notified &&
            !element.hideWarningBecauseThereIsANewerVersion &&
            _checkIfEventShouldBeNotified(
              element.info[0].severity,
            ),
      );

  void updateAlert(WarnMessage alert) {
    var alerts = List<WarnMessage>.from(state);

    if (alerts.contains(alert)) {
      alerts.updateEntry(alert);
    } else {
      // New from polling
      alerts.add(alert);
    }

    state = alerts;
  }

  /// checks if there can be a notification for a warning in [_warnings]
  Future<void> sendNotificationForWarnings() async {
    var updatedWarnings = <WarnMessage>[];

    for (WarnMessage warning in state) {
      var place = places.firstWhere(
        (place) => place.subscriptionId == warning.placeSubscriptionId,
      );

      if ((!warning.read &&
              !warning.notified &&
              !warning.isUpdateOfAlreadyNotifiedWarning) &&
          _checkIfEventShouldBeNotified(warning.info[0].severity)) {
        await NotificationService.showNotification(
          // generate from the warning in the List the notification id
          // because the warning identifier is no int, we have to generate a hash code
          id: warning.identifier.hashCode,
          title: "Neue Warnung für ${place.name}",
          body: warning.info[0].headline,
          payload: place.name,
          channel: warning.info[0].severity.name,
        );
      } else if (warning.isUpdateOfAlreadyNotifiedWarning &&
          !warning.notified &&
          !warning.read) {
        await await NotificationService.showNotification(
          // generate from the warning in the List the notification id
          // because the warning identifier is no int, we have to generate a hash code
          id: warning.identifier.hashCode,
          title: "Update einer Warnung für ${place.name}",
          body: warning.info[0].headline,
          payload: place.name,
          channel: "de.nucleus.foss_warn.notifications_update",
        );
      }

      // Alert is not already read or shown as notification
      // set notified to true to avoid sending notification twice
      updatedWarnings.add(warning.copyWith(notified: true));
    }

    state = updatedWarnings;
  }

  /// set the read and notified status from all warnings to false
  /// used for debug purpose
  /// [@ref] to update view
  void resetReadAndNotificationStatusForAllWarnings() {
    state = [
      for (var alert in state) ...[
        alert.copyWith(
          read: false,
          notified: false,
        ),
      ],
    ];
  }

  /// Return [true] if the user wants a notification - [false] if not.
  ///
  /// The source should be listed in the List notificationSourceSettings.
  /// check if the user wants to be notified for
  /// the given source and the given severity
  ///
  /// example:
  ///
  /// Warning severity | Notification setting | notification?   <br>
  /// Moderate (2)     | Minor (3)            | 3 >= 2 => true  <br>
  /// Minor (3)        | Moderate (2)         | 2 >= 3 => false
  bool _checkIfEventShouldBeNotified(Severity severity) =>
      Severity.getIndexFromSeverity(
        userPreferences.notificationSourceSetting.notificationLevel,
      ) >=
      Severity.getIndexFromSeverity(severity);
}
