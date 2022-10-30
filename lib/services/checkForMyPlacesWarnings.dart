import 'package:foss_warn/services/apiHandler.dart';
import 'package:foss_warn/views/SettingsView.dart';

import '../class/class_WarnMessage.dart';
import '../class/class_Place.dart';
import '../class/class_Geocode.dart';
import '../class/class_Area.dart';

import '../class/class_NotificationService.dart';
import 'generateNotificationID.dart';
import 'listHandler.dart';

import 'markWarningsAsNotified.dart';
import 'saveAndLoadSharedPreferences.dart';

/// check all warnings if one of them is of a myPlace and if yes send a notification <br>
/// [true] if there are/is a warning - false if not <br>
/// [useEtag]: if the etags should be used while calling the API
Future<bool> checkForMyPlacesWarnings(bool useEtag, bool loadManuel) async {
  bool returnValue = true;
  int countMessages = 0;
  print("check for warnings");
  print("warnMessageList: " + warnMessageList.length.toString());
  // load warnings if the list is empty / or we war in background
  if (warnMessageList.isEmpty || loadManuel) {
    // list ist empty, get data first
    print("Warninglist is empty or we ware in Background mode");
    await  callAPI();
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

  // inform user if he hasn't add any places yet
  if(myPlaceList.isEmpty) {
    await NotificationService.showNotification(
        3,
        "Sie haben noch keine Orte hinterlegt",
        "Bitte kontrolieren Sie Ihre Orte.",
        "keine Orte hinterlegt",
        "Hinweise");
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
          if(myGeocode.geocodeNumber.length < 5 || myPlace.geocode.length < 5 ) {
            // the geocode is not long enoug -> in case of alert swiss
            break;
          }
          if (myGeocode.geocodeName == myPlace.name ||
              // we have to cut the geocode because the warning are only on kreisebene
              // we have to check if the geocode ist lager then 5 because of alertSwiss
              myGeocode.geocodeNumber.substring(0, 5) ==
                      myPlace.geocode.substring(0, 5)) {
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
            print("add warning für: " + myPlace.name);
            countMessages++;
            myPlace.warnings.add(warnMessage);
          }
        }
      }
      myPlace.countWarnings = countMessages;
    }
  }

  print("Checke jetzt, ob Warnungen für hinterlegte Orte vorliegen");

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
            checkIfEventShouldBeNotified(myWarnMessage.event)) {
          // Alert is not already read or shown as notification
          print("markOneWarningAsNotified ");
          markOneWarningAsNotified(myWarnMessage);
          clearWarningAsNotifiedList();

          await NotificationService.showNotification(
              // generate from the warning in the List the notification id
              // because the warning identifier is no int, we have to generate a hash code
              generateNotificationID(myWarnMessage.identifier),
              "Neue Warnung für ${myPlace.name}",
              "${myWarnMessage.headline}",
              myPlace.name,
              myWarnMessage.severity);
        }
      }
      //return true - there are warnings. the return value isn't use yet?
      returnValue = true;
    } else {
      print("there is no warning or the warning is not in "
          "the notificationSettingsImportance list");
      //return false - there are no warning.  the return value isn't use yet?
      returnValue = false;
    }
  }
  return returnValue;
}

bool checkIfEventShouldBeNotified(String event) {
  if (notificationEventsSettings[event] != null) {
    print(event + " " + notificationEventsSettings[event]!.toString());
    return notificationEventsSettings[event]!;
  } else {
    return true;
  }
}
