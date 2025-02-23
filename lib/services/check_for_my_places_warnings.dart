import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/main.dart';
import 'package:foss_warn/services/api_handler.dart';
import 'package:foss_warn/services/list_handler.dart';
import '../class/class_notification_service.dart';

/// check all warnings if one of them is of a myPlace and if yes send a notification <br>
/// [true] if there are/is a warning - false if not <br>
Future<bool> checkForMyPlacesWarnings({
  required AlertAPI alertApi,
  required MyPlacesService myPlacesService,
  required List<Place> places,
}) async {
  bool returnValue = true;
  debugPrint("check for warnings");

  // get data first
  await callAPI(
    alertApi: alertApi,
    places: places,
  );

  // inform user if he hasn't add any places yet
  // @todo move to own timed function or find solution to not show a notification if the app is started the first time
  // @todo add translation

  if (places.isEmpty && !userPreferences.isFirstStart) {
    await NotificationService.showNotification(
      id: 3,
      title:
          "Sie haben noch keine Orte hinterlegt", //@todo translate, add context first, notification_no_places_selected_title
      body:
          "Bitte kontrolieren Sie Ihre Orte.", //notification_no_places_selected_body
      payload: "no places selected",
      channel: "other",
    );
  }

  for (Place myPlace in places) {
    // wait until every notification is send before saving the
    // myPlacesList with the new notified status
    await myPlace.sendNotificationForWarnings();
  }
  // save new notified status
  await myPlacesService.set(places);
  return returnValue; //@todo remove return value?
}
