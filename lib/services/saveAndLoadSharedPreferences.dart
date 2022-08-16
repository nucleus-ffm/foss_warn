import 'dart:convert';

import 'package:foss_warn/views/SettingsView.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../class/class_Place.dart';
import 'listHandler.dart';
import '../main.dart';

//My Places
saveMyPlacesList() async {
  //List<String> myPlaceListAsString = myPlaceList.map((i) => i.name).toList();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  // preferences.setStringList('myPlaceListAsString', myPlaceListAsString);
  preferences.setString("MyPlacesListAsJson", jsonEncode(myPlaceList));
}

loadMyPlacesList() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  /*List<String> myPlaceListAsString = [];
  if (preferences.containsKey("myPlaceListAsString")) {
    myPlaceListAsString = preferences.getStringList('myPlaceListAsString')!;
    myPlaceList.clear();
    for (String i in myPlaceListAsString) {
      myPlaceList.add(Place(name: i));
    }
  } */
  if (preferences.containsKey("MyPlacesListAsJson")) {
    var data  = jsonDecode(preferences.getString("MyPlacesListAsJson")!);
    myPlaceList.clear();
    for(int i = 0; i < data.length; i++) {
      myPlaceList.add(Place(name: data[i]["name"], geocode: data[i]["geocode"]));
    }
  }

}

saveGeocodes(var jsonFile) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("geocodes", jsonEncode(jsonFile));
}

Future<String?> loadGeocode()  async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.containsKey("geocodes")) {
    return jsonDecode(preferences.getString("geocodes")!);
  } else {
    return null;
  }
}


//Settings

saveReadWarningsList() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setStringList("readWarningsList", readWarnings);
}



loadReadWarningsList() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.containsKey("readWarningsList")) {
    readWarnings = preferences.getStringList("readWarningsList")!;
  }
}

saveAlreadyNotifiedWarningsList() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setStringList("AlreadyNotifiedWarningsList", alreadyNotifiedWarnings);
}

loadAlreadyNotifiedWarningsList() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.containsKey("AlreadyNotifiedWarningsList")) {
    alreadyNotifiedWarnings = preferences.getStringList("AlreadyNotifiedWarningsList")!;
  }
}

saveSettings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("notificationGeneral", notificationGeneral.toString());
  preferences.setString("startScreen", startScreen.toString());
  preferences.setString("showExtendedMetaData", showExtendedMetaData.toString());
  preferences.setString("warningFontSize", warningFontSize.toString());
  preferences.setString("showWelcomeScreen", showWelcomeScreen.toString());
  preferences.setString("sortWarningsBy", sortWarningsBy.toString());
  preferences.setString("showStatusNotification", showStatusNotification.toString());
  preferences.setString("updateAvailable", updateAvailable.toString());
  preferences.setString("githubVersionNumber", githubVersionNumber.toString());
  preferences.setString("frequencyOfAPICall", frequencyOfAPICall.toString());
  preferences.setString("useDarkMode", useDarkMode.toString());
  preferences.setString("showAllWarnings", showAllWarnings.toString());
  preferences.setString("notificationEventsSettings", jsonEncode(notificationEventsSettings));
  preferences.setBool("activateAlertSwiss", activateAlertSwiss);
  print("Settings saved");
}

saveEtags() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("mowasEtag", mowasEtag);
  preferences.setString("biwappEtag", biwappEtag);
  preferences.setString("katwarnEtag", katwarnEtag);
  preferences.setString("dwdEtag", dwdEtag);
  preferences.setString("lhpEtag", lhpEtag);
  print("etags saved");
}

loadEtags() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.containsKey("mowasEtag")) {
    String temp = preferences.getString("mowasEtag")!;
    mowasEtag = temp;
  }
  if (preferences.containsKey("biwappEtag")) {
    String temp = preferences.getString("biwappEtag")!;
    biwappEtag = temp;
  }
  if (preferences.containsKey("katwarnEtag")) {
    String temp = preferences.getString("katwarnEtag")!;
    katwarnEtag = temp;
  }
  if (preferences.containsKey("dwdEtag")) {
    String temp = preferences.getString("dwdEtag")!;
    dwdEtag = temp;
  }
  if (preferences.containsKey("lhpEtag")) {
    String temp = preferences.getString("lhpEtag")!;
    lhpEtag = temp;
  }
}

loadSettings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  if (preferences.containsKey("notificationGeneral")) {
    String temp = preferences.getString("notificationGeneral")!;
    if (temp == "true") {
      notificationGeneral = true;
    } else {
      notificationGeneral = false;
    }
  } else {
    notificationGeneral = true;
  }
  if (preferences.containsKey("startScreen")) {
    String temp = preferences.getString("startScreen")!;
    startScreen = int.parse(temp);
    print("Start Screen is: $startScreen");
  }
  if (preferences.containsKey("showExtendedMetaData")) {
    String temp = preferences.getString("showExtendedMetaData")!;
    if (temp == "true") {
      showExtendedMetaData = true;
    } else {
      showExtendedMetaData = false;
    }
  } else {
    showExtendedMetaData = false;
  }
  if (preferences.containsKey("warningFontSize")) {
    String temp = preferences.getString("warningFontSize")!;
    warningFontSize = double.parse(temp);
    print("warningFontSize: $warningFontSize");
  } else {
    saveSettings();
    loadSettings();
  }
  if (preferences.containsKey("showWelcomeScreen")) {
    String temp = preferences.getString("showWelcomeScreen")!;
    if (temp == "true") {
      showWelcomeScreen = true;
    } else {
      showWelcomeScreen = false;
    }
  } else {
    showWelcomeScreen = true;
  }
  if (preferences.containsKey("sortWarningsBy")) {
    String temp = preferences.getString("sortWarningsBy")!;
    sortWarningsBy = temp;
    //print("warningFontSize: $warningFontSize");
  } else {
    saveSettings();
    loadSettings();
  }
  if (preferences.containsKey("showStatusNotification")) {
    String temp = preferences.getString("showStatusNotification")!;
    if (temp == "true") {
      showStatusNotification = true;
    } else {
      showStatusNotification = false;
    }
  } else {
    showStatusNotification = true;
  }
  if (preferences.containsKey("updateAvailable")) {
    String temp = preferences.getString("updateAvailable")!;
    if (temp == "true") {
      updateAvailable = true;
    } else {
      updateAvailable = false;
    }
  } else {
    updateAvailable = false;
  }
  if (preferences.containsKey("githubVersionNumber")) {
    String temp = preferences.getString("githubVersionNumber")!;
    githubVersionNumber = temp;
    //print("warningFontSize: $warningFontSize");
  }
  if (preferences.containsKey("frequencyOfAPICall")) {
    frequencyOfAPICall =
        double.parse(preferences.getString("frequencyOfAPICall")!);
    //true;
  }
  if (preferences.containsKey("useDarkMode")) {
    String temp = preferences.getString("useDarkMode")!;
    if (temp == "true") {
      useDarkMode = true;
    } else {
      useDarkMode = false;
    }
  } else {
    useDarkMode = false;
  }
  if (preferences.containsKey("showAllWarnings")) {
    String temp = preferences.getString("showAllWarnings")!;
    if (temp == "true") {
      showAllWarnings = true;
    } else {
      showAllWarnings = false;
    }
  } else {
    showAllWarnings = false;
  }
  if (preferences.containsKey("notificationEventsSettings")) {
    String temp = preferences.getString("notificationEventsSettings")!;
    notificationEventsSettings = Map<String, bool>.from(jsonDecode(temp));
  }
  if (preferences.containsKey("activateAlertSwiss")) {
    activateAlertSwiss = preferences.getBool("activateAlertSwiss")!;
  }
}

saveNotificationSettingsImportanceList() async {
  print("Save saveNotificationSettingsImportanceList");
  notificationSettingsImportance.clear();
  if (notificationWithExtreme) {
    notificationSettingsImportance.add("extreme");
  }
  if (notificationWithSevere) {
    notificationSettingsImportance.add("severe");
  }
  if (notificationWithModerate) {
    notificationSettingsImportance.add("moderate");
  }
  if (notificationWithMinor) {
    notificationSettingsImportance.add("minor");
  }
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setStringList(
      'notificationSettingsImportance', notificationSettingsImportance);

  print(notificationSettingsImportance);
}

loadNotificationSettingsImportanceList() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  //check if notificationSettingsImportance already exsis
  if (preferences.containsKey("notificationSettingsImportance")) {
    print("notificationSettingsImportance exsis - load now");
    notificationSettingsImportance.clear();
    notificationSettingsImportance =
    preferences.getStringList('notificationSettingsImportance')!;
    notificationWithSevere = false;
    notificationWithModerate = false;
    notificationWithMinor = false;
    for (String i in notificationSettingsImportance) {
      if (i == "severe") {
        notificationWithSevere = true;
      } else if (i == "moderate") {
        notificationWithModerate = true;
      } else if (i == "minor") {
        notificationWithMinor = true;
      }
    }
  } else {
    print("notificationSettingsImportance Key does not exsis");
    saveNotificationSettingsImportanceList(); //save init List
    loadNotificationSettingsImportanceList(); // try again
    print("notificationSettingsImportance should yet exsis");
  }
}

cacheWarnings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("cachedWarnings", jsonEncode(warnMessageList));
  print("warnings saved");
}

loadCachedWarnings() async {
  SharedPreferences preferences =  await SharedPreferences.getInstance();
  if (preferences.containsKey("cachedWarnings")) {
    String temp = preferences.getString("cachedWarnings")!;
    warnMessageList = jsonDecode(temp);
    print(warnMessageList);
  } else {
    print("there are no saved warnings");
  }
}

