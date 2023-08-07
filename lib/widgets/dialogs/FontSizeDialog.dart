import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/saveAndLoadSharedPreferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FontSizeDialog extends StatefulWidget {
  const FontSizeDialog({Key? key}) : super(key: key);

  @override
  _FontSizeDialogState createState() => _FontSizeDialogState();
}

class _FontSizeDialogState extends State<FontSizeDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).font_size_headline),
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  AppLocalizations.of(context).font_size_small,
                  style: TextStyle(fontSize: 12),
                ),
                leading: Radio(
                  value: 12.0,
                  groupValue: userPreferences.warningFontSize,
                  onChanged: (value) {
                    setState(() {
                      userPreferences.warningFontSize = 12.0;
                      saveSettings();
                      Navigator.of(context).pop();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    userPreferences.warningFontSize = 12.0;
                    saveSettings();
                    Navigator.of(context).pop();
                  });
                },
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).font_size_normal,
                  style: TextStyle(fontSize: 14),
                ),
                leading: Radio(
                  value: 14.0,
                  groupValue: userPreferences.warningFontSize,
                  onChanged: (value) {
                    setState(() {
                      userPreferences.warningFontSize = 14.0;
                      saveSettings();
                      Navigator.of(context).pop();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    userPreferences.warningFontSize = 14.0;
                    saveSettings();
                    Navigator.of(context).pop();
                  });
                },
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).font_size_big,
                  style: TextStyle(fontSize: 16),
                ),
                leading: Radio(
                  value: 16,
                  groupValue: userPreferences.warningFontSize,
                  onChanged: (value) {
                    setState(() {
                      userPreferences.warningFontSize = 16.0;
                      saveSettings();
                      Navigator.of(context).pop();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    userPreferences.warningFontSize = 16.0;
                    saveSettings();
                    Navigator.of(context).pop();
                  });
                },
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).font_size_very_big,
                  style: TextStyle(fontSize: 18),
                ),
                leading: Radio(
                  value: 18.0,
                  groupValue: userPreferences.warningFontSize,
                  onChanged: (value) {
                    setState(() {
                      userPreferences.warningFontSize = 18.0;
                      saveSettings();
                      Navigator.of(context).pop();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    userPreferences.warningFontSize = 18.0;
                    saveSettings();
                    Navigator.of(context).pop();
                  });
                },
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
            AppLocalizations.of(context).main_dialog_close,
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }
}
