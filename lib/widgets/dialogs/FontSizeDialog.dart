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
    return SimpleDialog(
      title: Text(AppLocalizations.of(context)!.font_size_headline),
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.font_size_small,
                  style: TextStyle(fontSize: 12),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.abc),
                ),
                selectedColor: Theme.of(context).colorScheme.primary,
                selected:
                    userPreferences.warningFontSize == 12.0 ? true : false,
                onTap: () {
                  setState(() {
                    userPreferences.warningFontSize = 12.0;
                  });
                  saveSettings();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.font_size_normal,
                  style: TextStyle(fontSize: 14),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.abc),
                ),
                selectedColor: Theme.of(context).colorScheme.primary,
                selected:
                    userPreferences.warningFontSize == 14.0 ? true : false,
                onTap: () {
                  setState(() {
                    userPreferences.warningFontSize = 14.0;
                  });
                  saveSettings();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.font_size_big,
                  style: TextStyle(fontSize: 16),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.abc),
                ),
                selectedColor: Theme.of(context).colorScheme.primary,
                selected:
                    userPreferences.warningFontSize == 16.0 ? true : false,
                onTap: () {
                  setState(() {
                    userPreferences.warningFontSize = 16.0;
                  });
                  saveSettings();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.font_size_very_big,
                  style: TextStyle(fontSize: 18),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.abc),
                ),
                selectedColor: Theme.of(context).colorScheme.secondary,
                selected:
                    userPreferences.warningFontSize == 18.0 ? true : false,
                onTap: () {
                  setState(() {
                    userPreferences.warningFontSize = 18.0;
                  });
                  saveSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
