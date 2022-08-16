import 'package:foss_warn/services/saveAndLoadSharedPreferences.dart';

/// fix braking changes in old releases
void legacyHandler() {

  // fix change of the ImportanceList. It is now lowercase because of alert swiss
  saveNotificationSettingsImportanceList();

}