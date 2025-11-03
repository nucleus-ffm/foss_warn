import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:unifiedpush/unifiedpush.dart';
import '../../class/class_unified_push_handler.dart';
import '../../services/subscription_handler.dart';
import '../../services/url_launcher.dart';
import 'loading_screen.dart';

class NotificationTroubleshootDialog extends ConsumerStatefulWidget {
  const NotificationTroubleshootDialog({super.key});

  @override
  ConsumerState<NotificationTroubleshootDialog> createState() =>
      _NotificationTroubleshootDialogState();
}

class _NotificationTroubleshootDialogState
    extends ConsumerState<NotificationTroubleshootDialog> {
  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var navigator = Navigator.of(context);
    var userPreferences = ref.watch(userPreferencesProvider);

    return AlertDialog(
      title: Text(localizations.troubleshoot_notification_title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.troubleshoot_notification_register_state(
                userPreferences.unifiedPushRegistered,
              ),
            ),
            SelectableText(
              localizations.troubleshoot_notification_current_endpoint(
                userPreferences.unifiedPushEndpoint,
              ),
            ),
            Text(
              localizations.troubleshoot_notification_current_vapid_key(
                userPreferences.webPushVapidKey,
              ),
            ),
            Text(
              localizations.troubleshoot_notification_current_public_key(
                (userPreferences.webPushPublicKey),
              ),
            ),
            Text(
              localizations.troubleshoot_notification_current_auth_key(
                (userPreferences.webPushAuthKey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await UnifiedPush.unregister(
                  UserPreferences.unifiedPushInstance,
                );
                var unifiedPushHandler = ref.read(unifiedPushHandlerProvider);
                // @TODO(Nucleus): Calling onUnregistered shouldn't be necessary, but it currently is
                unifiedPushHandler
                    .onUnregistered(UserPreferences.unifiedPushInstance);
              },
              child: Text(
                localizations.troubleshoot_notification_unregister_for_push,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                var unifiedPushHandler = ref.read(unifiedPushHandlerProvider);
                unifiedPushHandler.setupUnifiedPush(context, ref);
              },
              child: const Text(
                "register",
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await UnifiedPush.unregister(
                  UserPreferences.unifiedPushInstance,
                );
                var unifiedPushHandler = ref.read(unifiedPushHandlerProvider);
                unifiedPushHandler
                    .onUnregistered(UserPreferences.unifiedPushInstance);
                if (!context.mounted) return;
                unifiedPushHandler.setupUnifiedPush(context, ref);
              },
              child: Text(
                localizations.troubleshoot_notification_reset_push_setup,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                LoadingScreen.instance().show(
                  context: context,
                  text: localizations.loading_screen_loading,
                );
                await resubscribeForAllArea(context, ref);
              },
              child: Text(localizations.troubleshoot_notification_resubscribe),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Icon(Icons.open_in_browser),
                Flexible(
                  fit: FlexFit.loose,
                  child: TextButton(
                    onPressed: () => launchUrlInBrowser(
                      'https://github.com/nucleus-ffm/foss_warn/wiki/What-is-UnifiedPush-and-how-to-select-a-distributor',
                    ),
                    child: Text(
                      localizations
                          .no_up_distributor_found_up_explanation_button,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.open_in_browser),
                Flexible(
                  fit: FlexFit.loose,
                  child: TextButton(
                    onPressed: () => launchUrlInBrowser(
                      'https://f-droid.org/de/packages/io.heckel.ntfy/',
                    ),
                    child: Text(
                      localizations.no_up_distributor_found_direct_link_to_ntfy,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => navigator.pop(),
          child: Text(localizations.main_dialog_close),
        ),
      ],
    );
  }
}
