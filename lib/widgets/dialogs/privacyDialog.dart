import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/urlLauncher.dart';

class PrivacyDialog extends StatefulWidget {
  const PrivacyDialog({Key? key}) : super(key: key);

  @override
  _PrivacyDialogState createState() => _PrivacyDialogState();
}

class _PrivacyDialogState extends State<PrivacyDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.privacy_headline),
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.privacy_main_text),
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
                            'https://warnung.bund.de/datenschutz'),
                        child: Text(AppLocalizations.of(context)
                                !.privacy_link_to_privacy +
                            " Warnung.bund.de")),
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
                            'https://www.xrepository.de/cms/datenschutz.html'),
                        child: Text(AppLocalizations.of(context)
                                !.privacy_link_to_privacy +
                            " xrepository.de")),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context)!.main_dialog_understand,
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }
}
