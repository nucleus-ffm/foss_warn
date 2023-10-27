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
      title: Text("${AppLocalizations.of(context)!.legacy_warning_dialog_title} ${userPreferences.versionNumber}"),
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [ //
              Text(AppLocalizations.of(context)!.legacy_warning_dialog_text)
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
