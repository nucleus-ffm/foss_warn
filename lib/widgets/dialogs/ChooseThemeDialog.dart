import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/main.dart';
import 'package:foss_warn/services/saveAndLoadSharedPreferences.dart';
import 'package:provider/provider.dart';

import '../../services/updateProvider.dart';

class ChooseThemeDialog extends StatefulWidget {
  const ChooseThemeDialog({Key? key}) : super(key: key);

  @override
  _ChooseThemeDialogState createState() => _ChooseThemeDialogState();
}

class _ChooseThemeDialogState extends State<ChooseThemeDialog> {
  List<Widget> generateBrightnessButtons() {
    List<ThemeMode> themeModes = [
      ThemeMode.light,
      ThemeMode.dark,
      ThemeMode.system
    ];
    List<Widget> result = [];
    for (ThemeMode tm in themeModes) {
      result.add(generateBrightnessButton(tm));
    }
    return result;
  }

  Widget generateBrightnessButton(ThemeMode themeMode) {
    return TextButton(
      style: TextButton.styleFrom(
          padding: EdgeInsets.only(left: 10, right: 10),
          backgroundColor: selectBackgroundColor(themeMode),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              side: BorderSide(
                  // change border color if theme is currently selected
                  color: (userPreferences.selectedThemeMode == themeMode)
                      ? Colors.green
                      : Colors.transparent,
                  width: 5))),
      onPressed: () {
        setState(() {
          userPreferences.selectedThemeMode = themeMode;
        });
        // Reload the full app for theme changes to reflect
        final updater = Provider.of<Update>(context, listen: false);
        updater.updateView();
        saveSettings();
      },
      child: Text(
        selectTextForThemeMode(themeMode),
        style: TextStyle(color: selectForegroundColor(themeMode)),
      ),
    );
  }

  String selectTextForThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return  AppLocalizations.of(context)!.settings_color_schema_light;
      case ThemeMode.dark:
        return AppLocalizations.of(context)!.settings_color_schema_dark;
      case ThemeMode.system:
        return AppLocalizations.of(context)!.settings_color_schema_auto;
      default:
        return "Error";
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
      default:
        return Colors.red;
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
      default:
        return Colors.red;
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
    return Container(
      width: 90,
      padding: EdgeInsets.all(1),
      child: TextButton(
        child: SizedBox(),
        onPressed: () {
          setState(() {
            if (userPreferences.selectedThemeMode == ThemeMode.light ||
                (userPreferences.selectedThemeMode == ThemeMode.system &&
                    MediaQuery.of(context).platformBrightness ==
                        Brightness.light)) {
              userPreferences.selectedLightTheme = theme;
            } else {
              userPreferences.selectedDarkTheme = theme;
            }
          });
          // Reload the full app for theme changes to reflect
          final updater = Provider.of<Update>(context, listen: false);
          updater.updateView();
          saveSettings();
        },
        style: TextButton.styleFrom(
          minimumSize: Size(80, 80),
          backgroundColor: theme.colorScheme.primary,
          shape: CircleBorder(
              side: BorderSide(
                  // change border color if theme is currently selected
                  color: (userPreferences.selectedLightTheme == theme ||
                          userPreferences.selectedDarkTheme == theme)
                      ? Colors.green
                      : Colors.transparent,
                  width: 5)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppLocalizations.of(context)!.choose_theme_dialog_headline),
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: generateBrightnessButtons(),
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                ),
                SizedBox(height: 10),
                Text(AppLocalizations.of(context)!.choose_theme_dialog_choose_accent_color),
                SizedBox(height: 10),
                Wrap(
                  children: [...generateAvailableThemes()],
                  alignment: WrapAlignment.center,
                  spacing: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
