import 'package:foss_warn/class/class_WarnMessage.dart';
import 'listHandler.dart';
import 'saveAndLoadSharedPreferences.dart';

/// add one warning to to list of already already notified warnings
markOneWarningAsNotified(WarnMessage myWarning) {
  if (alreadyNotifiedWarnings.contains(myWarning.identifier)) {
    print("Warnung bereits in der Liste");
  } else {
    print("add ${myWarning.identifier} to NotifiedWarnings list");
    alreadyNotifiedWarnings.add(myWarning.identifier);
    saveAlreadyNotifiedWarningsList();
  }
}

/// remove old read warning to clear the saved list
clearWarningAsNotifiedList() {
  List<String> removeList =  [];
  for (String id in readWarnings) {
    if (warnMessageList.any((myWarning) => myWarning.identifier == id)) {
      // Warn Message still in List
      print("Warn Message still in List");
    } else {
      //add to remove list
      print("remove: " + id);
      removeList.add(id);
    }
  }
  for (String id in removeList) {
    alreadyNotifiedWarnings.remove(id);
  }
}