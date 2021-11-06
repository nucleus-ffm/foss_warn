import 'package:flutter/material.dart';
import '../services/urlLauncher.dart';
import '../SettingsView.dart';
import '../services/saveAndLoadSharedPreferences.dart';

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
      title: Text('Wie sollen die Meldungen sortiert werden?'),
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  "Nach Herausgabedatum (neuste zuerst)",
                  //style: TextStyle(fontSize: 12),
                ),
                leading: Radio(
                  value: "date",
                  groupValue: sortWarningsBy,
                  onChanged: (value) {
                    setState(() {
                      sortWarningsBy = "date";
                      Navigator.of(context).pop();
                      saveSettings();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    sortWarningsBy = "date";
                    Navigator.of(context).pop();
                    saveSettings();
                  });
                },
              ),
              /*ListTile(
                title: Text(
                  "Nach Warnstufen (höchste zuerst)",
                  //style: TextStyle(fontSize: 14),
                ),
                leading: Radio(
                  value: "severity",
                  groupValue: sortWarningsBy,
                  onChanged: (value) {
                    setState(() {
                      sortWarningsBy = "severity";
                      Navigator.of(context).pop();
                      saveSettings();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    sortWarningsBy = "severity";
                    Navigator.of(context).pop();
                    saveSettings();
                  });
                },
              ),*/
              ListTile(
                title: Text(
                  "Nach Quellen",
                  //style: TextStyle(fontSize: 16),
                ),
                leading: Radio(
                  value: "source",
                  groupValue: sortWarningsBy,
                  onChanged: (value) {
                    setState(() {
                      sortWarningsBy = "source";
                      Navigator.of(context).pop();
                      saveSettings();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    sortWarningsBy = "source";
                    Navigator.of(context).pop();
                    saveSettings();
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
            'schließen',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
      backgroundColor: Colors.white,
    );
  }
}
