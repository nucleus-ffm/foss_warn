import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../class/class_Place.dart';
import '../class/class_WarnMessage.dart';
import '../services/updateProvider.dart';
import '../services/notification_service.dart';
import '../MyPlacesView.dart';
import 'saveAndLoadSharedPreferences.dart';
import 'listHandler.dart';


markAllWarningsAsRead(Place myPlace, BuildContext context) {
  //myPlace.alreadyReadWarnings.clear();
  //myPlace.alreadyReadWarnings = myPlace.warnings;
  for (WarnMessage myWarning in myPlace.warnings) {
    if (readWarnings.contains(myWarning.identifier)) {
      print("Warnung bereits in der Liste");
    } else {
      readWarnings.add(myWarning.identifier);
      saveReadWarningsList();
      final updater =
      Provider.of<Update>(context, listen: false);
      updater.updateReadStatusInList();

    }
  }
}
markAllWarningsAsReadFromMain(BuildContext context) {
  //myPlace.alreadyReadWarnings.clear();
  //myPlace.alreadyReadWarnings = myPlace.warnings;
  for (WarnMessage myWarning in warnMessageList) {
    if (readWarnings.contains(myWarning.identifier)) {
      print("Warnung bereits in der Liste");
    } else {
      readWarnings.add(myWarning.identifier);
      saveReadWarningsList();
      final updater =
      Provider.of<Update>(context, listen: false);
      updater.updateReadStatusInList();
    }
  }
}

markOneWarningAsRead(WarnMessage myWarning,  BuildContext context) {
  if (readWarnings.contains(myWarning.identifier)) {
    print("Warnung bereits in der Liste");
  } else {
    readWarnings.add(myWarning.identifier);
    saveReadWarningsList();
    final updater =
    Provider.of<Update>(context, listen: false);
    updater.updateReadStatusInList();

  }
}
markOneWarningAsReadFromDetailView(WarnMessage myWarning) {
  if (readWarnings.contains(myWarning.identifier)) {
    print("Warnung bereits in der Liste");
  } else {
    readWarnings.add(myWarning.identifier);
    saveReadWarningsList();
    NotificationService.cancelAllNotification();
  }
}

markOneWarningAsUnread(WarnMessage myWarning,  BuildContext context) {
  if (readWarnings.contains(myWarning.identifier)) {
    readWarnings.remove(myWarning.identifier);
    saveReadWarningsList();
    final updater =
    Provider.of<Update>(context, listen: false);
    updater.updateReadStatusInList();
  } else { //warnung nicht als gelesen markiert
  }
}

clearReadWarningsList()  {
  for (String id in readWarnings) {
    if (warnMessageList.any((myWarning) => myWarning.identifier == id)) {
      //Warn Message still in List
      print("Warn Message still in List");
    } else {
      //remove from readWarningList
      print("remove: " + id);
      readWarnings.remove(id);
    }
  }

}