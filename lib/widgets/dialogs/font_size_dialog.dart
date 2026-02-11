import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/extensions/context.dart';

class FontSizeDialog extends ConsumerStatefulWidget {
  const FontSizeDialog({super.key});

  @override
  ConsumerState<FontSizeDialog> createState() => _FontSizeDialogState();
}

class _FontSizeDialogState extends ConsumerState<FontSizeDialog> {
  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var theme = Theme.of(context);
    var navigator = Navigator.of(context);

    var userPreferences = ref.watch(userPreferencesProvider);
    var userPreferencesService = ref.read(userPreferencesProvider.notifier);

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
                  userPreferencesService.setWarningFontSize(12.0);
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
                  userPreferencesService.setWarningFontSize(14.0);
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
                  userPreferencesService.setWarningFontSize(16.0);
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
                  userPreferencesService.setWarningFontSize(18.0);
                  navigator.pop();
                },
              ),
              ListTile(
                title: const Text(
                  "TV Size", //@TODO translate
                  style: TextStyle(fontSize: 25),
                ),
                leading: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.abc),
                ),
                selectedColor: theme.colorScheme.secondary,
                selected:
                userPreferences.warningFontSize == 25.0 ? true : false,
                onTap: () {
                  userPreferencesService.setWarningFontSize(25.0);
                  navigator.pop();
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}
