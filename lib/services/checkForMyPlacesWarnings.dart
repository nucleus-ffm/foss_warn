import 'package:foss_warn/services/apiHandler.dart';
import '../class/class_NotificationService.dart';
import '../class/abstract_Place.dart';

import 'listHandler.dart';
import 'saveAndLoadSharedPreferences.dart';

/// check all warnings if one of them is of a myPlace and if yes send a notification <br>
/// [true] if there are/is a warning - false if not <br>
/// [useEtag]: if the etags should be used while calling the API
Future<bool> checkForMyPlacesWarnings(bool useEtag, bool loadManually) async {
  bool _returnValue = true;
  print("check for warnings");
  // get data first
  await callAPI();
  if (notificationSettingsImportance.isEmpty) {
    print("notificationSettingsImportanceList is empty");
    await loadNotificationSettingsImportanceList();
    print(notificationSettingsImportance);
  }
  if (myPlaceList.isEmpty) {
    print("myPlaceList is empty - load list");
    await loadMyPlacesList();
  }

  // inform user if he hasn't add any places yet
  // @todo move to own timed function or find solution to not show a notification if the app is started the first time
  // @todo add translation
  if (myPlaceList.isEmpty) {
    await NotificationService.showNotification(
        id: 3,
        title: "Sie haben noch keine Orte hinterlegt",
        body: "Bitte kontrolieren Sie Ihre Orte.",
        payload: "keine Orte hinterlegt",
        channel: "other");
  }

  for (Place myPlace in myPlaceList) {
    myPlace.sendNotificationForWarnings();
  }
  return _returnValue; //@todo remove return value?
}
