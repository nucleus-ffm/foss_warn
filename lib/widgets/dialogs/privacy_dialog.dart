import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/main.dart';
import '../../services/url_launcher.dart';

class PrivacyDialog extends StatefulWidget {
  const PrivacyDialog({super.key});

  @override
  State<PrivacyDialog> createState() => _PrivacyDialogState();
}

class _PrivacyDialogState extends State<PrivacyDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.privacy_headline),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!
                .privacy_main_text
                .replaceAll("\\n", "\n")),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(Icons.open_in_browser),
                Flexible(
                  fit: FlexFit.loose,
                  child: TextButton(
                      onPressed: () => launchUrlInBrowser(
                          'https://osmfoundation.org/wiki/Privacy_Policy'),
                      child: Text(
                          "${AppLocalizations.of(context)!.privacy_link_to_privacy} Openstreetmap.org")),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.open_in_browser),
                Flexible(
                  fit: FlexFit.loose,
                  child: TextButton(
                      onPressed: () => launchUrlInBrowser(
                          userPreferences.fossPublicAlertServerPrivacyNotice),
                      child: Text(
                          "${AppLocalizations.of(context)!.privacy_link_to_privacy} the FOSS Public Alert Server")),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context)!.main_dialog_understand,
          ),
        ),
      ],
    );
  }
}
