import 'package:foss_warn/SettingsView.dart';
import 'package:foss_warn/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../MyPlacesView.dart';
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

saveSettings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("notificationGeneral", notificationGeneral.toString());
  preferences.setString("startScreen", startScreen.toString());
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

loadFrequencyOfAPICall() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.containsKey("frequencyOfAPICall")) {
    frequencyOfAPICall =
        double.parse(preferences.getString("frequencyOfAPICall")!);
    //true;
  } // else false
}

saveFrequencyOfAPICall() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("frequencyOfAPICall", frequencyOfAPICall.toString());
}