import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/listHandler.dart';
import '../services/updateProvider.dart';
import '../views/SettingsView.dart';
import 'class_NotificationService.dart';
import 'class_WarnMessage.dart';

abstract class Place {
  final String name;
  int countWarnings = 0;
  List<WarnMessage> warnings = [];

  Place({required this.name, required this.warnings}) {
    countWarnings = this.warnings.length;
  }

  String getName() => name;

  // check if all warnings in `warnings` are
  // also in the alreadyReadWarnings list
  bool checkIfAllWarningsAreRead() {
    for (WarnMessage myWarning in warnings) {
      if (!myWarning.read) {
        // there is min. one warning not read
        return false;
      }
    }
    return true;
  }

  /// check if there is warning in the [warnings] which is not yet in the
  /// alreadyNotifiedWarnings list.
  /// return [true] if there is warning which no notification
  bool checkIfThereIsAWarningToNotify() {
    for (WarnMessage myWarning in warnings) {
      if (!myWarning.notified &&
          notificationSettingsImportance.contains(myWarning.severity)) {
        // there is min. one warning without notification
        return true;
      }
    }
    return false;
  }

  /// checks if there can be a notification for a warning in [warnings]
  Future<void> sendNotificationForWarnings() async {
    for (WarnMessage myWarnMessage in warnings) {
      print(myWarnMessage.headline);
      print("notified:" +
          ((!myWarnMessage.read && !myWarnMessage.notified) &&
                  _checkIfEventShouldBeNotified(myWarnMessage.event))
              .toString());
      if ((!myWarnMessage.read && !myWarnMessage.notified) &&
          _checkIfEventShouldBeNotified(myWarnMessage.event)) {
        // Alert is not already read or shown as notification
        // set notified to true to avoid sending notification twice
        myWarnMessage.notified = true;

        await NotificationService.showNotification(
            // generate from the warning in the List the notification id
            // because the warning identifier is no int, we have to generate a hash code
            id: myWarnMessage.identifier.hashCode,
            title: "Neue Warnung für $name",
            body: "${myWarnMessage.headline}",
            payload: name,
            channel: myWarnMessage.severity);
      } else {
        print("there is no warning or the warning is not in "
            "the notificationSettingsImportance list");
      }
    }
  }

  /// set the read status from all warnings to true
  /// @context to update view
  void markAllWarningsAsRead(BuildContext context) {
    for (WarnMessage myWarnMessage in warnings) {
      myWarnMessage.read = true;
    }
    final updater = Provider.of<Update>(context, listen: false);
    updater.updateReadStatusInList();
  }

  /// set the read and notified status from all warnings to false
  /// used for debug purpose
  /// @context to update view
  void resetReadAndNotificationStatusForAllWarnings(BuildContext context) {
    for (WarnMessage myWarnMessage in warnings) {
      myWarnMessage.read = false;
      myWarnMessage.notified = false;
    }
    final updater = Provider.of<Update>(context, listen: false);
    updater.updateReadStatusInList();
  }

  bool _checkIfEventShouldBeNotified(String event) {
    if (notificationEventsSettings[event] != null) {
      print(event + " " + notificationEventsSettings[event]!.toString());
      return notificationEventsSettings[event]!;
    } else {
      return true;
    }
  }
}
