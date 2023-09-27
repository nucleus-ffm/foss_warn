import 'package:foss_warn/main.dart';

import '../class/class_NinaPlace.dart';
import '../class/class_WarnMessage.dart';
import '../class/abstract_Place.dart';
import 'alertSwiss.dart';
import 'listHandler.dart';
import 'sendStatusNotification.dart';
import 'saveAndLoadSharedPreferences.dart';

/// call the nina api and load for myPlaces the warnings
Future<void> callAPI() async {
  bool _successfullyFetched = true;
  String _error = "";
  List<WarnMessage> _tempWarnMessageList = [];
  _tempWarnMessageList.clear();
  // String geocode = "071110000000"; // just for testing

  print("call API");

  await loadSettings();
  await loadMyPlacesList();

  for (Place place in myPlaceList) {
    String SingleError;
    bool status;
    // call function to load warnings from the API
    (SingleError, status) = await place.callAPIAndGetWarnings();
    if (SingleError != "") {
      _error += SingleError;
    }
    if (!status) {
      _successfullyFetched = false;
    }
  }
  // if enabled call warning for current place
  if (userPreferences.warningsForCurrentLocation) {
    userPreferences.currentPlace?.callAPIAndGetWarnings();
  }

  // update status notification if the user wants
  if (userPreferences.showStatusNotification) {
    if (_error != "") {
      sendStatusUpdateNotification(_successfullyFetched, _error);
    } else {
      sendStatusUpdateNotification(_successfullyFetched);
    }
  }

  // call alert Swiss
  if (userPreferences.activateAlertSwiss) {
    await callAlertSwissAPI();
  }

  print("finished calling API");
}


/// check if stored warnings are still up-to-date and remove if not
void removeOldWarningFromList(
    NinaPlace place, List<WarnMessage> tempWarnMessageList) {
  // remove old warnings
  List<WarnMessage> warnMessagesToRemove = [];
  for (WarnMessage msg in place.warnings) {
    if (!tempWarnMessageList.any((tmp) => tmp.identifier == msg.identifier)) {
      warnMessagesToRemove.add(msg);
    }
  }
  for (WarnMessage message in warnMessagesToRemove) {
    place.removeWarningFromList(message);
    place.decrementNumberOfWarnings();
  }
}
