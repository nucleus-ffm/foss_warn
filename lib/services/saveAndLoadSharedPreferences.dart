import 'package:foss_warn/views/SettingsView.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../class/class_Place.dart';
import 'listHandler.dart';

//My Places
saveMyPlacesList() async {
  List<String> myPlaceListAsString = myPlaceList.map((i) => i.name).toList();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setStringList('myPlaceListAsString', myPlaceListAsString);
}

loadMyPlacesList() async {
  List<String> myPlaceListAsString = myPlaceList.map((i) => i.name).toList();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.containsKey("myPlaceListAsString")) {
    myPlaceListAsString = preferences.getStringList('myPlaceListAsString')!;
    myPlaceList.clear();
    for (String i in myPlaceListAsString) {
      myPlaceList.add(Place(name: i));
    }
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
  print("Settings saved");
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
  if(preferences.containsKey("warningFontSize")) {
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
  if(preferences.containsKey("sortWarningsBy")) {
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
  if(preferences.containsKey("githubVersionNumber")) {
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
}

saveNotificationSettingsImportanceList() async {
  print("Save saveNotificationSettingsImportanceList");
  notificationSettingsImportance.clear();
  if (notificationWithExtreme) {
    notificationSettingsImportance.add("Extreme");
  }
  if (notificationWithSevere) {
    notificationSettingsImportance.add("Severe");
  }
  if (notificationWithModerate) {
    notificationSettingsImportance.add("Moderate");
  }
  if (notificationWithMinor) {
    notificationSettingsImportance.add("Minor");
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
      if (i == "Severe") {
        notificationWithSevere = true;
      } else if (i == "Moderate") {
        notificationWithModerate = true;
      } else if (i == "Minor") {
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