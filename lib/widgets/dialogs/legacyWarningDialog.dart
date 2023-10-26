import 'package:flutter/material.dart';
import '../../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LegacyWarningDialog extends StatefulWidget {
  const LegacyWarningDialog({Key? key}) : super(key: key);

  @override
  _LegacyWarningDialogState createState() => _LegacyWarningDialogState();
}

class _LegacyWarningDialogState extends State<LegacyWarningDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Updated version to ${userPreferences.versionNumber}"),
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  "FOSSWarn is now updated to a new version."
                      " With this new version we have improved the internal "
                      "structure of the app. Externally there is no big change,"
                      " but we had to reset all settings and saved locations."
                      " Please check your settings and add your places again. "
                      "\n\nThank you for your understanding and sorry for the inconvenience.")
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
            AppLocalizations.of(context)!.main_dialog_close,
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }
}
