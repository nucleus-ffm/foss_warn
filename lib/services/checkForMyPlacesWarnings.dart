import 'package:foss_warn/views/SettingsView.dart';

import '../class/class_WarnMessage.dart';
import '../class/class_Place.dart';
import '../class/class_Geocode.dart';
import '../class/class_Area.dart';

import '../class/class_NotificationService.dart';
import 'generateNotificationID.dart';
import 'getData.dart';
import 'listHandler.dart';

import 'markWarningsAsNotified.dart';
import 'saveAndLoadSharedPreferences.dart';

/// check all warnings if one of them is of a myPlace and if yes send a notification
/// returns true if there are/is a warning - false if not
Future<bool> checkForMyPlacesWarnings(bool useEtag) async {
  bool returnValue = true;
  print("check for warnings");
  int countMessages = 0;
  print("warnMessageList: " + warnMessageList.length.toString());
  if (warnMessageList.isEmpty || useEtag) {
    print("Warninglist is empty or we ware in Background mode"); // list ist emty, get data first
    await getData(useEtag);
  }
  if (notificationSettingsImportance.isEmpty) {
    print("notificationSettingsImportanceList is empty");
    await loadNotificationSettingsImportanceList();
    print(notificationSettingsImportance);
  }
  if (myPlaceList.isEmpty) {
    print("myPlaceList is empty - load list");
    await loadMyPlacesList();
  }
  if (readWarnings.isEmpty) {
    print("readWarningsList is empty - load list");
    await loadReadWarningsList();
  }
  if (alreadyNotifiedWarnings.isEmpty) {
    print("loadAlreadyNotifiedWarningsList is empty - load list");
    await loadAlreadyNotifiedWarningsList();
  }

  void sendNotification(
      int id, String title, String body, String payload, String channel) async {
    await NotificationService.showNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
      channel: channel,
    );
  }

  for (Place myPlace in myPlaceList) {
    //clear Warning List
    myPlace.warnings.clear();
    countMessages = 0;
    //check for warning in MyPlaces
    print("Liste wurde geleert");
    for (WarnMessage warnMessage in warnMessageList) {
      //print(warnMessage.headline);
      for (Area myArea in warnMessage.areaList) {
        for (Geocode myGeocode in myArea.geocodeList) {
          //print(name);
          if (myGeocode.geocodeName == myPlace.name) {
            if (myPlace.warnings.contains(warnMessage)) {
              print("Warn Messsage already in List");
              //warn messeage already in list from geocodename
            } else {
              print("Add Warning for: " + myPlace.name);
              countMessages++;
              myPlace.warnings.add(warnMessage);
            }
          }
        }
        if (myArea.areaDesc.contains(myPlace.name)) {
          print("Area Decs contains myPlace name: " + myPlace.name);
          if (myPlace.warnings.contains(warnMessage)) {
            print("Warn Messsage already in List");
            //warn messeage already in list from geocodename
          } else {
            print("add warning f??r: " + myPlace.name);
            countMessages++;
            myPlace.warnings.add(warnMessage);
          }
        }
      }
      myPlace.countWarnings = countMessages;
    }
  }

  print("Checke jetzt, ob Warnungen f??r hinterlegte Orte vorliegen");

  for (Place myPlace in myPlaceList) {
    print("In der Liste sind: " + notificationSettingsImportance.toString());
    //check if there are warning and if it they are important enough
    if (myPlace.warnings.length > 0 &&
        myPlace.warnings.any((warning) =>
            notificationSettingsImportance.contains(warning.severity))) {
      print("Warnung vorhanden");
      //check if there are new Warnings

      for (WarnMessage myWarnMessage in myPlace.warnings) {
        if (!readWarnings.contains(myWarnMessage.identifier) &&
            !alreadyNotifiedWarnings.contains(myWarnMessage.identifier) &&
            checkIfEventShouldBeNotified(myWarnMessage.event)
        ) {
          // Alert is not already read or shown as notification
          print("markOneWarningAsNotified ");
          markOneWarningAsNotified(myWarnMessage);
          clearWarningAsNotifiedList();
        
          sendNotification(
              // generate from the warning in the List the notification id
              // because the warning identifier is no int, we have to generate a hash code
              generateNotificationID(myWarnMessage.identifier),
              "Neue Warnung f??r ${myPlace.name}",
              "${myWarnMessage.headline}",
              myPlace.name,
              myWarnMessage.severity);
        }
      }
      //return true - there are warnings. the return value isn't use yet?
      returnValue = true;
    } else {
      //return false - there are no warning.  the return value isn't use yet?
      returnValue = false;
    }
  }
  return returnValue;
}

bool checkIfEventShouldBeNotified(String event) {
  if(notificationEventsSettings[event] != null) {
    print(event + " " + notificationEventsSettings[event]!.toString());
    return notificationEventsSettings[event]!;
  } else {
    return true;
  }
}
