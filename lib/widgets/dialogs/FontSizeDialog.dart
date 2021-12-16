import 'package:flutter/material.dart';
import '../../views/SettingsView.dart';
import '../../services/saveAndLoadSharedPreferences.dart';

class FontSizeDialog extends StatefulWidget {
  const FontSizeDialog({Key? key}) : super(key: key);

  @override
  _FontSizeDialogState createState() => _FontSizeDialogState();
}

class _FontSizeDialogState extends State<FontSizeDialog> {
  List fontSizeList = [8, 9, 10, 11, 12, 13, 14, 15, 16];
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Wähle eine Schriftgröße'),
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  "klein",
                  style: TextStyle(fontSize: 12),
                ),
                leading: Radio(
                  value: 12.0,
                  groupValue: warningFontSize,
                  onChanged: (value) {
                    setState(() {
                      warningFontSize = 12.0;
                      saveSettings();
                      Navigator.of(context).pop();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    warningFontSize = 12.0;
                    saveSettings();
                    Navigator.of(context).pop();
                  });
                },
              ),
              ListTile(
                title: Text(
                  "Normal",
                  style: TextStyle(fontSize: 14),
                ),
                leading: Radio(
                  value: 14.0,
                  groupValue: warningFontSize,
                  onChanged: (value) {
                    setState(() {
                      warningFontSize = 14.0;
                      saveSettings();
                      Navigator.of(context).pop();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    warningFontSize = 14.0;
                    saveSettings();
                    Navigator.of(context).pop();
                  });
                },
              ),
              ListTile(
                title: Text(
                  "Groß",
                  style: TextStyle(fontSize: 16),
                ),
                leading: Radio(
                  value: 16,
                  groupValue: warningFontSize,
                  onChanged: (value) {
                    setState(() {
                      warningFontSize = 16.0;
                      saveSettings();
                      Navigator.of(context).pop();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    warningFontSize = 16.0;
                    saveSettings();
                    Navigator.of(context).pop();
                  });
                },
              ),
              ListTile(
                title: Text(
                  "Extragroß",
                  style: TextStyle(fontSize: 18),
                ),
                leading: Radio(
                  value: 18.0,
                  groupValue: warningFontSize,
                  onChanged: (value) {
                    setState(() {
                      warningFontSize = 18.0;
                      saveSettings();
                      Navigator.of(context).pop();
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    warningFontSize = 18.0;
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
            'schließen',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }
}
