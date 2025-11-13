import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/services/update_loop.dart';

import '../class/class_app_state.dart';
import '../class/class_user_preferences.dart';
import '../constants.dart';

/// self check that is performed in the background to detect proactive
/// problems with the notification setup
/// This is a basic check with checks:
/// - if there is an endpoint stored
/// - if the selected server is on the list of server that are not working
///
/// returns true, is there is an error,
/// false if there was no problem detected
bool backgroundSelfCheck(UserPreferences userPreferences) {
  // check if UP is registered
  if (!userPreferences.unifiedPushRegistered) {
    return true;
  }
  // check if there is an endpoint
  String endpoint = userPreferences.unifiedPushEndpoint;
  if (endpoint == "") {
    return true;
  }

  // check if the server is blacklisted
  for (String serverName in serverThatAreNotWorking) {
    if (endpoint.contains(serverName)) {
      return true;
    }
  }
  return false;
}

/// Provider to periodically check in the background the push  notification setup
/// detect errors
final selfCheckProvider = Provider<void>((ref) {
  ref.listen(tickingChangeProvider(250), (_, event) {
    var appStateService = ref.read(appStateProvider.notifier);
    appStateService.setPushNotificationSetupError(
      backgroundSelfCheck(ref.read(userPreferencesProvider)),
    );
  });
});
