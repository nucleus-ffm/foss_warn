import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/extensions/context.dart';
import '../../services/url_launcher.dart';

class PrivacyDialog extends ConsumerStatefulWidget {
  const PrivacyDialog({super.key});

  @override
  ConsumerState<PrivacyDialog> createState() => _PrivacyDialogState();
}

class _PrivacyDialogState extends ConsumerState<PrivacyDialog> {
  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var navigator = Navigator.of(context);

    var userPreferences = ref.watch(userPreferencesProvider);

    return AlertDialog(
      title: Text(localizations.privacy_headline),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.privacy_main_text.replaceAll("\\n", "\n"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.open_in_browser),
                Flexible(
                  fit: FlexFit.loose,
                  child: TextButton(
                    onPressed: () => launchUrlInBrowser(
                      'https://osmfoundation.org/wiki/Privacy_Policy',
                    ),
                    child: Text(
                      "${localizations.privacy_link_to_privacy} Openstreetmap.org",
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
                      userPreferences.fossPublicAlertServerPrivacyNotice,
                    ),
                    child: Text(
                      "${localizations.privacy_link_to_privacy} the FOSS Public Alert Server",
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
          child: Text(localizations.main_dialog_understand),
        ),
      ],
    );
  }
}
