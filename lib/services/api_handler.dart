import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/main.dart';

import '../class/class_warn_message.dart';
import 'list_handler.dart';
import 'send_status_notification.dart';
import 'save_and_load_shared_preferences.dart';

/// call the FPAS api and load for myPlaces the warnings
Future<void> callAPI() async {
  bool successfullyFetched = true;
  String error = "";
  List<WarnMessage> tempWarnMessageList = [];
  tempWarnMessageList.clear();

  debugPrint("call API");

  await loadMyPlacesList();

  for (Place place in myPlaceList) {
    await place.callAPI();

    // set flag for updated alerts
    for (WarnMessage wm in place.warnings) {
      if (wm.references != null) {
        // the alert contains a reference, so it is an update of an previous alert
        // we search for the alert and add it to the update thread

        for (String id in wm.references!.identifier) {
          // check all warnings for references
          for (WarnMessage alWm in place.warnings) {
            debugPrint(alWm.identifier);
            if (alWm.identifier.compareTo(id) == 0) {
              // set flag to true to hide the previous alert in the overview
              alWm.hideWarningBecauseThereIsANewerVersion =
                  true; //@todo move to better location
            }
          }
        }
      }
    }
  }
  // update status notification if the user wants
  if (userPreferences.showStatusNotification) {
    if (error != "") {
      sendStatusUpdateNotification(successfullyFetched, error);
    } else {
      sendStatusUpdateNotification(successfullyFetched);
    }
  }

  debugPrint("finished calling API");
}
