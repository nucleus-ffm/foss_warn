import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/listHandler.dart';
import '../services/updateProvider.dart';
import '../views/SettingsView.dart';
import 'class_NotificationService.dart';
import 'class_WarnMessage.dart';

abstract class Place {
  final String _name;
  int _countWarnings = 0;
  List<WarnMessage> _warnings = [];

  Place({required String name, required List<WarnMessage> warnings}) : _warnings = warnings, _name = name {
    _countWarnings = this._warnings.length;
  }

  String getName() => _name;
  int getCountWarnings() => _countWarnings;
  void incrementNumberOfWarnings() => _countWarnings++;
  void decrementNumberOfWarnings() => _countWarnings--;
  List<WarnMessage> getWarnings() => _warnings;
  void addWarningToList(WarnMessage warnMessage) => _warnings.add(warnMessage);
  void removeWarningFromList(WarnMessage warnMessage) => _warnings.remove(warnMessage);
  

  // check if all warnings in `warnings` are
  // also in the alreadyReadWarnings list
  bool checkIfAllWarningsAreRead() {
    for (WarnMessage myWarning in _warnings) {
      if (!myWarning.read) {
        // there is min. one warning not read
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
          notificationSettingsImportance.contains(myWarning.severity)) {
        // there is min. one warning without notification
        return true;
      }
    }
    return false;
  }

  /// checks if there can be a notification for a warning in [_warnings]
  Future<void> sendNotificationForWarnings() async {
    for (WarnMessage myWarnMessage in _warnings) {
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
            title: "Neue Warnung für $_name",
            body: "${myWarnMessage.headline}",
            payload: _name,
            channel: myWarnMessage.severity.name);
      } else {
        print("there is no warning or the warning is not in "
            "the notificationSettingsImportance list");
      }
    }
  }

  /// set the read status from all warnings to true
  /// @context to update view
  void markAllWarningsAsRead(BuildContext context) {
    for (WarnMessage myWarnMessage in _warnings) {
      myWarnMessage.read = true;
    }
    final updater = Provider.of<Update>(context, listen: false);
    updater.updateReadStatusInList();
  }

  /// set the read and notified status from all warnings to false
  /// used for debug purpose
  /// @context to update view
  void resetReadAndNotificationStatusForAllWarnings(BuildContext context) {
    for (WarnMessage myWarnMessage in _warnings) {
      myWarnMessage.read = false;
      myWarnMessage.notified = false;
    }
    final updater = Provider.of<Update>(context, listen: false);
    updater.updateReadStatusInList();
  }

  /// return true or false if the warning should be irgnored or not
  /// The event could be listed in the map notificationEventsSettings.
  /// if it is listed in the map, return the stored value for the event
  /// If not return as default true
  bool _checkIfEventShouldBeNotified(String event) {
    if (notificationEventsSettings[event] != null) {
      print(event + " " + notificationEventsSettings[event]!.toString());
      return notificationEventsSettings[event]!;
    } else {
      return true;
    }
  }
}
