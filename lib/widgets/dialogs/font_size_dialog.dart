import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/main.dart';

class FontSizeDialog extends StatefulWidget {
  const FontSizeDialog({super.key});

  @override
  State<FontSizeDialog> createState() => _FontSizeDialogState();
}

class _FontSizeDialogState extends State<FontSizeDialog> {
  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var theme = Theme.of(context);
    var navigator = Navigator.of(context);

    return SimpleDialog(
      title: Text(localizations.font_size_headline),
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  localizations.font_size_small,
                  style: const TextStyle(fontSize: 12),
                ),
                leading: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.abc),
                ),
                selectedColor: theme.colorScheme.primary,
                selected:
                    userPreferences.warningFontSize == 12.0 ? true : false,
                onTap: () {
                  setState(() {
                    userPreferences.warningFontSize = 12.0;
                  });
                  navigator.pop();
                },
              ),
              ListTile(
                title: Text(
                  localizations.font_size_normal,
                  style: const TextStyle(fontSize: 14),
                ),
                leading: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.abc),
                ),
                selectedColor: theme.colorScheme.primary,
                selected:
                    userPreferences.warningFontSize == 14.0 ? true : false,
                onTap: () {
                  setState(() {
                    userPreferences.warningFontSize = 14.0;
                  });

                  navigator.pop();
                },
              ),
              ListTile(
                title: Text(
                  localizations.font_size_big,
                  style: const TextStyle(fontSize: 16),
                ),
                leading: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.abc),
                ),
                selectedColor: theme.colorScheme.primary,
                selected:
                    userPreferences.warningFontSize == 16.0 ? true : false,
                onTap: () {
                  setState(() {
                    userPreferences.warningFontSize = 16.0;
                  });

                  navigator.pop();
                },
              ),
              ListTile(
                title: Text(
                  localizations.font_size_very_big,
                  style: const TextStyle(fontSize: 18),
                ),
                leading: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.abc),
                ),
                selectedColor: theme.colorScheme.secondary,
                selected:
                    userPreferences.warningFontSize == 18.0 ? true : false,
                onTap: () {
                  setState(() {
                    userPreferences.warningFontSize = 18.0;
                  });

                  navigator.pop();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
