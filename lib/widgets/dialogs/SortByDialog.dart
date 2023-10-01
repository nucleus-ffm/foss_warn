import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../main.dart';
import '../../services/saveAndLoadSharedPreferences.dart';

class SortByDialog extends StatefulWidget {
  @override
  _SortByDialogState createState() => _SortByDialogState();
}

class _SortByDialogState extends State<SortByDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).sorting_headline),
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  AppLocalizations.of(context).sorting_by_date
                ),
                leading: Radio(
                  value: "date",
                  groupValue: userPreferences.sortWarningsBy,
                  onChanged: (value) {
                    setState(() {
                      userPreferences.sortWarningsBy = "date";
                    });

                    saveSettings();
                    Navigator.of(context).pop();
                  },
                ),
                onTap: () {
                  setState(() {
                    userPreferences.sortWarningsBy = "date";
                  });

                  saveSettings();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).sorting_by_warning_level
                ),
                leading: Radio(
                  value: "severity",
                  groupValue: userPreferences.sortWarningsBy,
                  onChanged: (value) {
                    setState(() {
                      userPreferences.sortWarningsBy = "severity";
                      saveSettings();
                      Navigator.of(context).pop();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    userPreferences.sortWarningsBy = "severity";
                    saveSettings();
                    Navigator.of(context).pop();
                  });
                },
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).sorting_by_source
                ),
                leading: Radio(
                  value: "source",
                  groupValue: userPreferences.sortWarningsBy,
                  onChanged: (value) {
                    setState(() {
                      userPreferences.sortWarningsBy = "source";
                      saveSettings();
                      Navigator.of(context).pop();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    userPreferences.sortWarningsBy = "source";
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
          child: Text(AppLocalizations.of(context).main_dialog_close,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        ),
      ],
    );
  }
}
