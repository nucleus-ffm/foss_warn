import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/main.dart';

import '../../services/update_provider.dart';

class ChooseThemeDialog extends ConsumerStatefulWidget {
  const ChooseThemeDialog({super.key});

  @override
  ConsumerState<ChooseThemeDialog> createState() => _ChooseThemeDialogState();
}

class _ChooseThemeDialogState extends ConsumerState<ChooseThemeDialog> {
  List<Widget> generateBrightnessButtons() {
    List<ThemeMode> themeModes = [
      ThemeMode.light,
      ThemeMode.dark,
      ThemeMode.system,
    ];
    List<Widget> result = [];
    for (ThemeMode tm in themeModes) {
      result.add(generateBrightnessButton(tm));
    }
    return result;
  }

  Widget generateBrightnessButton(ThemeMode themeMode) {
    var updater = ref.read(updaterProvider);

    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.only(left: 10, right: 10),
        backgroundColor: selectBackgroundColor(themeMode),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          side: BorderSide(
            // change border color if theme is currently selected
            color: (userPreferences.selectedThemeMode == themeMode)
                ? Colors.green
                : Colors.transparent,
            width: 5,
          ),
        ),
      ),
      onPressed: () {
        setState(() {
          userPreferences.selectedThemeMode = themeMode;
        });
        // Reload the full app for theme changes to reflect
        updater.updateView();
      },
      child: Text(
        selectTextForThemeMode(themeMode),
        style: TextStyle(color: selectForegroundColor(themeMode)),
      ),
    );
  }

  String selectTextForThemeMode(ThemeMode themeMode) {
    var localizations = context.localizations;

    switch (themeMode) {
      case ThemeMode.light:
        return localizations.settings_color_schema_light;
      case ThemeMode.dark:
        return localizations.settings_color_schema_dark;
      case ThemeMode.system:
        return localizations.settings_color_schema_auto;
    }
  }

  Color selectBackgroundColor(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Colors.white;
      case ThemeMode.dark:
        return Colors.black;
      case ThemeMode.system:
        return Colors.grey;
    }
  }

  Color selectForegroundColor(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Colors.black;
      case ThemeMode.dark:
        return Colors.white;
      case ThemeMode.system:
        return Colors.black;
    }
  }

  /// generate from the list of available themes a list of button
  /// with the primary colors
  List<Widget> generateAvailableThemes() {
    List<Widget> result = [];

    if (userPreferences.selectedThemeMode == ThemeMode.light ||
        (userPreferences.selectedThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.light)) {
      for (ThemeData th in userPreferences.availableLightThemes) {
        result.add(generateColorButton(th));
      }
    } else {
      for (ThemeData th in userPreferences.availableDarkThemes) {
        result.add(generateColorButton(th));
      }
    }
    return result;
  }

  Widget generateColorButton(ThemeData theme) {
    var mediaQuery = MediaQuery.of(context);

    var updater = ref.read(updaterProvider);

    return Container(
      width: 90,
      padding: const EdgeInsets.all(1),
      child: TextButton(
        onPressed: () {
          setState(() {
            if (userPreferences.selectedThemeMode == ThemeMode.light ||
                (userPreferences.selectedThemeMode == ThemeMode.system &&
                    mediaQuery.platformBrightness == Brightness.light)) {
              userPreferences.selectedLightTheme = theme;
            } else {
              userPreferences.selectedDarkTheme = theme;
            }
          });
          // Reload the full app for theme changes to reflect
          updater.updateView();
        },
        style: TextButton.styleFrom(
          minimumSize: const Size(80, 80),
          backgroundColor: theme.colorScheme.primary,
          shape: CircleBorder(
            side: BorderSide(
              // change border color if theme is currently selected
              color: (userPreferences.selectedLightTheme == theme ||
                      userPreferences.selectedDarkTheme == theme)
                  ? Colors.green
                  : Colors.transparent,
              width: 5,
            ),
          ),
        ),
        child: const SizedBox(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    return SimpleDialog(
      title: Text(localizations.choose_theme_dialog_headline),
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: generateBrightnessButtons(),
                ),
                const SizedBox(height: 10),
                Text(localizations.choose_theme_dialog_choose_accent_color),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  children: [...generateAvailableThemes()],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
