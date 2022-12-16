import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../views/SettingsView.dart';
import '../../services/saveAndLoadSharedPreferences.dart';

class SortByDialog extends StatefulWidget {
  const SortByDialog({Key? key}) : super(key: key);

  @override
  _SortByDialogState createState() => _SortByDialogState();
}

class _SortByDialogState extends State<SortByDialog> {
  List fontSizeList = [8, 9, 10, 11, 12, 13, 14, 15, 16];
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
                  AppLocalizations.of(context).sorting_by_date,
                  //style: TextStyle(fontSize: 12),
                ),
                leading: Radio(
                  value: "date",
                  groupValue: sortWarningsBy,
                  onChanged: (value) {
                    setState(() {
                      sortWarningsBy = "date";
                      saveSettings();
                      Navigator.of(context).pop();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    sortWarningsBy = "date";
                    saveSettings();
                    Navigator.of(context).pop();
                  });
                },
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).sorting_by_warning_level,
                  //style: TextStyle(fontSize: 14),
                ),
                leading: Radio(
                  value: "severity",
                  groupValue: sortWarningsBy,
                  onChanged: (value) {
                    setState(() {
                      sortWarningsBy = "severity";
                      saveSettings();
                      Navigator.of(context).pop();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    sortWarningsBy = "severity";
                    saveSettings();
                    Navigator.of(context).pop();
                  });
                },
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).sorting_by_source,
                  //style: TextStyle(fontSize: 16),
                ),
                leading: Radio(
                  value: "source",
                  groupValue: sortWarningsBy,
                  onChanged: (value) {
                    setState(() {
                      sortWarningsBy = "source";
                      saveSettings();
                      Navigator.of(context).pop();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    sortWarningsBy = "source";
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
          child: Text(AppLocalizations.of(context).main_dialog_close, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        ),
      ],
    );
  }
}
