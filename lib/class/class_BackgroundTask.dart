import 'package:workmanager/workmanager.dart';

import 'package:foss_warn/views/SettingsView.dart';
import 'package:foss_warn/services/checkForMyPlacesWarnings.dart';

/// this function is called when the workmanager task is executed
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    bool response = false;
    print("Native called background task: " + task);
    switch (task) {
      case "call APIs":
      // load warnings in Background and notify if necessary
        response = await checkForMyPlacesWarnings();
        print("Call APIs executed");
        break;
    }
    //simpleTask will be emitted here.
    return Future.value(response);
  });
}

/// class with all needed methodes for the background taks with workmanager
class BackgroundTaskManager {

  /// initialize workmanager
  void initialize() {
    Workmanager().initialize(
        callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode:
        false // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );
  }

  /// stops all existing background tasks
  void cancelBackgroundTask() {
    Workmanager().cancelAll();
  }

  /// creates a new background task to call the APIs
  void registerBackgroundTask() {
    Workmanager().registerPeriodicTask(
        "1", "call APIs",
        inputData: null,
        /*constraints: Constraints(
          networkType: NetworkType.connected,
        ),*/
        frequency: Duration(minutes: frequencyOfAPICall.toInt()));
  }

  void registerBackgroundTaskWithDelay() {
    Workmanager().registerPeriodicTask(
        "1", "call APIs",
        /*constraints: Constraints(
          networkType: NetworkType.connected,
        ),*/
        frequency: Duration(minutes: frequencyOfAPICall.toInt()),
        initialDelay: Duration(minutes: frequencyOfAPICall.toInt()));
  }

}