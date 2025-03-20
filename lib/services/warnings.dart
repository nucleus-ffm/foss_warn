import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/enums/sorting_categories.dart';
import 'package:foss_warn/main.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/update_loop.dart';

// TODO(PureTryOut): cache retrieved alerts on disk rather than in memory
final processedAlertsProvider =
    StateNotifierProvider<WarningService, List<WarnMessage>>(
  (ref) {
    return WarningService(places: ref.watch(myPlacesProvider));
  },
);

final alertsForPlaceFutureProvider =
    FutureProvider.family<List<WarnMessage>, String>(
        (ref, subscriptionId) async {
  var alertApi = ref.read(alertApiProvider);

  var alerts = await alertApi.getAlerts(subscriptionId: subscriptionId);

  return Future.wait([
    for (var alert in alerts) ...[
      alertApi.getAlertDetail(
        alertId: alert,
        placeSubscriptionId: subscriptionId,
      ),
    ],
  ]);
});

final alertsFutureProvider = FutureProvider<List<WarnMessage>>((ref) async {
  var places = ref.watch(myPlacesProvider);

  var alertsForPlaces = await Future.wait(
    [
      for (var place in places) ...[
        ref.watch(alertsForPlaceFutureProvider(place.subscriptionId).future),
      ],
    ],
  );

  // Bring it back down to one big list
  return [
    for (var alerts in alertsForPlaces) ...[
      ...alerts,
    ],
  ];
});

/// Provides a complete list of all warnings for subscribed places.
///
/// It polls for new alerts and merges the result with any locally processed/modified alerts.
/// Any processing on alerts has to be done through [processedAlertsProvider].
final alertsProvider = Provider<List<WarnMessage>>((ref) {
  ref.listen(tickingChangeProvider(100), (_, event) {
    ref.invalidate(alertsForPlaceFutureProvider);
  });

  var processedAlerts = ref.watch(processedAlertsProvider);
  var alertsSnapshot = ref.watch(alertsFutureProvider);

  if (!alertsSnapshot.hasValue) return processedAlerts;

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

  var mergedAlerts = <WarnMessage>[];
  for (var alert in alertsSnapshot.requireValue) {
    var indexOfAlert = processedAlerts.indexOf(alert);

    if (indexOfAlert == -1) {
      mergedAlerts.add(alert);
    } else {
      mergedAlerts.add(processedAlerts[indexOfAlert]);
    }
  }

  // Determine which alert is an update of a previous one
  var updatedWarnings = <WarnMessage>[];
  for (var alert in mergedAlerts) {
    updatedWarnings.add(
      alert.copyWith(
        isUpdateOfAlreadyNotifiedWarning: isAlertAnUpdate(
          existingWarnings: mergedAlerts,
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
      var alWm =
          mergedAlerts.firstWhere((alert) => alert.identifier == referenceId);
      mergedAlerts.updateEntry(
        alWm.copyWith(hideWarningBecauseThereIsANewerVersion: true),
      );
    }
  }

  return sortWarnings(mergedAlerts);
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
  WarningService({required this.places}) : super(<WarnMessage>[]);

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
