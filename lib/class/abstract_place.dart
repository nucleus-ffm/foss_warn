import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_notification_preferences.dart';
import 'package:foss_warn/enums/warning_source.dart';
import 'package:foss_warn/services/save_and_load_shared_preferences.dart';

import '../enums/severity.dart';
import '../main.dart';
import '../services/update_provider.dart';
import 'class_notification_service.dart';
import 'class_warn_message.dart';

abstract class Place {
  final String _name;
  final List<WarnMessage> _warnings;
  String eTag;

  Place({
    required String name,
    required List<WarnMessage> warnings,
    required this.eTag,
  })  : _warnings = warnings,
        _name = name;

  String get name => _name;
  int get countWarnings => warnings.length;
  List<WarnMessage> get warnings => _warnings;

  // control the list for warnings
  void addWarningToList(WarnMessage warnMessage) => _warnings.add(warnMessage);
  void removeWarningFromList(WarnMessage warnMessage) =>
      _warnings.remove(warnMessage);

  // check if all warnings in `warnings` are
  // also in the alreadyReadWarnings list
  bool checkIfAllWarningsAreRead() {
    for (WarnMessage myWarning in _warnings) {
      if (!myWarning.read &&
          !myWarning.hideWarningBecauseThereIsANewerVersion) {
        // there is min. one warning not read and which is not an update
        debugPrint("found unread warning: ${myWarning.info.first.headline}");
        return false;
      }
    }
    return true;
  }

  /// check if there is warning in the [_warnings] which is not yet in the
  /// alreadyNotifiedWarnings list.
  /// return [true] if there is warning which no notification
  bool checkIfThereIsAWarningToNotify() {
    for (WarnMessage myWarning in _warnings) {
      if (!myWarning.notified &&
          !myWarning.hideWarningBecauseThereIsANewerVersion &&
          _checkIfEventShouldBeNotified(
              myWarning.source, myWarning.info[0].severity)) {
        // there is min. one warning without notification
        return true;
      }
    }
    return false;
  }

  /// checks if there can be a notification for a warning in [_warnings]
  Future<void> sendNotificationForWarnings() async {
    for (WarnMessage myWarnMessage in _warnings) {
      debugPrint(myWarnMessage.info[0].headline);
      //print("Read: " + myWarnMessage.read.toString()  + " notified " + myWarnMessage.notified.toString());
      /*print("should notify? :" +
          (_checkIfEventShouldBeNotified(
                  myWarnMessage.source, myWarnMessage.severity))
              .toString());c*/
      //(!myWarnMessage.read && !myWarnMessage.notified) &&

      if ((!myWarnMessage.read &&
              !myWarnMessage.notified &&
              !myWarnMessage.isUpdateOfAlreadyNotifiedWarning) &&
          _checkIfEventShouldBeNotified(
              myWarnMessage.source, myWarnMessage.info[0].severity)) {
        // Alert is not already read or shown as notification
        // set notified to true to avoid sending notification twice
        myWarnMessage.notified = true;

        await NotificationService.showNotification(
            // generate from the warning in the List the notification id
            // because the warning identifier is no int, we have to generate a hash code
            id: myWarnMessage.identifier.hashCode,
            title: "Neue Warnung für $_name",
            body: myWarnMessage.info[0].headline,
            payload: _name,
            channel: myWarnMessage.info[0].severity.name);
      } else if (myWarnMessage.isUpdateOfAlreadyNotifiedWarning &&
          !myWarnMessage.notified &&
          !myWarnMessage.read) {
        myWarnMessage.notified = true;
        await await NotificationService.showNotification(
            // generate from the warning in the List the notification id
            // because the warning identifier is no int, we have to generate a hash code
            id: myWarnMessage.identifier.hashCode,
            title: "Update einer Warnung für $_name",
            body: myWarnMessage.info[0].headline,
            payload: _name,
            channel: "de.nucleus.foss_warn.notifications_update");
      } else {
        debugPrint("there is no warning or the warning is not in "
            "the notificationSettingsImportance list");
      }
    }
  }

  /// set the read status from all warnings to true
  /// @context to update view
  void markAllWarningsAsRead(WidgetRef ref) {
    for (WarnMessage myWarnMessage in _warnings) {
      myWarnMessage.read = true;
      NotificationService.cancelOneNotification(
          myWarnMessage.identifier.hashCode);
    }
    final updater = ref.read(updaterProvider);
    updater.updateReadStatusInList();
    saveMyPlacesList();
  }

  /// set the read and notified status from all warnings to false
  /// used for debug purpose
  /// [@context] to update view
  void resetReadAndNotificationStatusForAllWarnings(WidgetRef ref) {
    for (WarnMessage myWarnMessage in _warnings) {
      myWarnMessage.read = false;
      myWarnMessage.notified = false;
    }
    final updater = ref.read(updaterProvider);
    updater.updateReadStatusInList();
    saveMyPlacesList();
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
  bool _checkIfEventShouldBeNotified(WarningSource source, Severity severity) {
    NotificationPreferences notificationSourceSetting = userPreferences
        .notificationSourceSettings
        .firstWhere((element) => element.warningSource == source);

    return notificationSourceSetting.disabled == false &&
        Severity.getIndexFromSeverity(
                notificationSourceSetting.notificationLevel) >=
            Severity.getIndexFromSeverity(severity);
  }
}
