import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/enums/sorting_categories.dart';
import 'package:foss_warn/main.dart';
import 'package:foss_warn/services/list_handler.dart';

final warningsProvider =
    StateNotifierProvider<WarningService, List<WarnMessage>>(
  (ref) => WarningService(places: ref.watch(myPlacesProvider)),
);

class WarningService extends StateNotifier<List<WarnMessage>> {
  WarningService({required this.places}) : super([]);

  final List<Place> places;

  List<WarnMessage> _sortWarnings(List<WarnMessage> warnings) {
    var sortedWarnings = List<WarnMessage>.of(state);

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

  void set(List<WarnMessage> warnings) {
    if (!mounted) return;
    state = _sortWarnings(warnings);
  }

  bool hasWarningToNotify() => state.any(
        (element) =>
            !element.notified &&
            !element.hideWarningBecauseThereIsANewerVersion &&
            _checkIfEventShouldBeNotified(
              element.info[0].severity,
            ),
      );

  void clearWarningsForPlace(Place place) {
    state = _sortWarnings(
      List<WarnMessage>.from(
        state.where(
          (element) => element.placeSubscriptionId != place.subscriptionId,
        ),
      ),
    );
  }

  void updateWarning(WarnMessage warning) {
    var warnings = List<WarnMessage>.from(state);
    warnings.updateEntry(warning);
    state = _sortWarnings(warnings);
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

      state = updatedWarnings;
    }
  }

  /// set the read status from all warnings to true
  /// @ref to update view
  void markAllWarningsAsRead() {
    var updatedWarnings = <WarnMessage>[];

    for (var warning in state) {
      NotificationService.cancelOneNotification(warning.identifier.hashCode);

      updatedWarnings.add(warning.copyWith(read: true));
    }

    state = updatedWarnings;
  }

  /// set the read and notified status from all warnings to false
  /// used for debug purpose
  /// [@ref] to update view
  void resetReadAndNotificationStatusForAllWarnings() {
    var updatedWarnings = <WarnMessage>[];

    for (var warning in state) {
      updatedWarnings.add(warning.copyWith(read: false, notified: false));
    }
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
