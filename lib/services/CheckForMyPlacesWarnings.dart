import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../MyPlacesView.dart';
import '../main.dart';
import '../class/class_WarnMessage.dart';
import '../class/class_Place.dart';
import '../class/class_Geocode.dart';
import '../class/class_Area.dart';

import '../services/notification_service.dart';
import 'GetData.dart';
import '../SettingsView.dart';
import 'listHandler.dart';

import 'saveAndLoadSharedPreferences.dart';

Future<bool> checkForWarnings() async {
  bool returnValue = true;
  print("check for warnings");
  int countMessages = 0;
  print("warnMessageList: " + warnMessageList.length.toString());
  if (warnMessageList.isEmpty) {
    print("Warninglist is empty");
    await getData();
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

  sendNotification(int id, String title, String body, String payload) async {
    await NotificationService.showNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
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
            countMessages++;
            myPlace.warnings.add(warnMessage);
          }
        }
        if(myArea.areaDesc.contains(myPlace.name)) {
          print("Area Decs contrains myPlace name:" + myPlace.name);
          if(myPlace.warnings.contains(warnMessage)) {
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
      if (myPlace.warnings
          .every((warning) => readWarnings.contains(warning.identifier))) {
        print("keine neue Meldungen");
      } else {
        if (myPlace.warnings.length > 1) {
          //if just one Warning
          String generateBody() {
            int counter = 1;
            String returnBody = "";
            for (WarnMessage warnMessage in myPlace.warnings) {
              returnBody +=
                  counter.toString() + ": " + warnMessage.headline + "\n";
              counter++;
            }
            return returnBody;
            //<br>1. Warnung: </br> ${myPlace.warnings.first.headline} ...
          }

          sendNotification(
              Random().nextInt(100),
              "Es gibt ${myPlace.warnings.length.toString()} Warnungen für ${myPlace.name}",
              generateBody(),
              myPlace.name);
        } else {
          // if more then one warning
          sendNotification(
              Random().nextInt(100),
              "Es gibt ${myPlace.warnings.length.toString()} Warnung für ${myPlace.name}",
              "Warnung: ${myPlace.warnings.first.headline}",
              myPlace.name);
        }
      }
      //return true - there are wanrings
      returnValue = true;
    } else {
      //return false - there are no warning
      returnValue = false;
    }
  }
  return returnValue;
}
