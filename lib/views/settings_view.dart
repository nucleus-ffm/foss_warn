import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foss_warn/services/fpas.dart';
import 'package:foss_warn/views/dev_settings_view.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../services/url_launcher.dart';
import '../widgets/dialogs/choose_theme_dialog.dart';
import 'notification_settings_view.dart';
import 'introduction/introduction_view.dart';

import '../widgets/dialogs/font_size_dialog.dart';
import '../widgets/dialogs/sort_by_dialog.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController frequencyController = TextEditingController();
  final TextEditingController fpasServerURLController = TextEditingController();
  bool _fpasServerURLError = false;
  final _platform = const MethodChannel("flutter.native/helper");

  @override
  void initState() {
    frequencyController.text =
        userPreferences.frequencyOfAPICall.toInt().toString();
    fpasServerURLController.text =
        userPreferences.fossPublicAlertServerUrl.toString();

    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double indentOfCategoriesTitles = 15;

    final Map<int, String> startViewLabels = {
      0: AppLocalizations.of(context)!.settings_start_view_all_warnings,
      1: AppLocalizations.of(context)!.settings_start_view_only_my_places,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: indentOfCategoriesTitles,
                  top: indentOfCategoriesTitles),
              child: Text(
                AppLocalizations.of(context)!.settings_notification,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!
                  .settings_android_notification_settings),
              onTap: () => _openNotificationSettings(),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!
                  .settings_app_notification_settings),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationSettingsView()),
                );
              },
            ),
            /*ListTile(
                title: Text(AppLocalizations.of(context)!
                    .settings_show_status_notification_title),
                subtitle: Text(AppLocalizations.of(context)!
                    .settings_show_status_notification_subtitle),
                trailing: Switch(
                    value: userPreferences.showStatusNotification,
                    onChanged: (value) {
                      setState(() {
                        userPreferences.showStatusNotification = value;
                      });
                      saveSettings();
                      if (userPreferences.showStatusNotification == false) {
                        NotificationService.cancelOneNotification(1);
                      }
                    })),
            ListTile(
              title: Text(
                  AppLocalizations.of(context)!.settings_background_service),
              trailing: Switch(
                  value: userPreferences.shouldNotifyGeneral,
                  //@todo maybe we should add a confirmation dialog to prevent accidentally disabled background updates
                  onChanged: (value) {
                    setState(() {
                      userPreferences.shouldNotifyGeneral = value;
                    });
                    saveSettings();
                    if (userPreferences.shouldNotifyGeneral) {
                      AlarmManager().cancelBackgroundTask();
                      AlarmManager().registerBackgroundTask();
                    } else {
                      AlarmManager().cancelBackgroundTask();
                      print("background notification disabled");
                    }
                  }),
            ),
            userPreferences.shouldNotifyGeneral ?
            ListTile(
              title: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!
                            .settings_frequent_of_background_update),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 70,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: frequencyController,
                                onChanged: (value) {
                                  if (value != "") {
                                    if (double.parse(value) > 0 &&
                                        double.parse(value) <=
                                            _maxValueFrequencyOfAPICall) {
                                      setState(() {
                                        userPreferences.frequencyOfAPICall =
                                            double.parse(value);
                                      });
                                    } else {
                                      frequencyController.text = userPreferences
                                          .frequencyOfAPICall
                                          .round()
                                          .toString();
                                    }
                                  }
                                },
                                onTapOutside: (e) {
                                  // Check whether the text field is in focus,
                                  // because this method is executed every time
                                  // you tap somewhere in the settings, even
                                  // if the text field is not in focus at all
                                  if (FocusScope.of(context).isFirstFocus) {
                                    FocusScope.of(context).unfocus();
                                    saveSettings();
                                    AlarmManager().cancelBackgroundTask();
                                    AlarmManager().registerBackgroundTask();
                                    callAPI(); // call api and update notification
                                  }
                                },
                                onEditingComplete: () {
                                  FocusScope.of(context).unfocus();
                                  saveSettings();
                                  AlarmManager().cancelBackgroundTask();
                                  AlarmManager().registerBackgroundTask();
                                  callAPI(); // call api and update notification
                                },
                                decoration: InputDecoration(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Text("min"),
                            Expanded(
                              child: Slider(
                                value: userPreferences.frequencyOfAPICall,
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                                min: 1,
                                max: _maxValueFrequencyOfAPICall,
                                onChanged: (value) {
                                  setState(() {
                                    userPreferences.frequencyOfAPICall =
                                        value.roundToDouble();
                                    frequencyController.text = userPreferences
                                        .frequencyOfAPICall
                                        .toInt()
                                        .toString();
                                  });
                                },
                                onChangeEnd: (value) {
                                  saveSettings();
                                  AlarmManager().cancelBackgroundTask();
                                  AlarmManager().registerBackgroundTask();
                                  callAPI(); // call api and update notification
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ) : SizedBox(),
            */
            Divider(
              height: 50,
              indent: 15.0,
              endIndent: 15.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: indentOfCategoriesTitles),
              child: Text(
                "FOSS Public Alert Server", //@todo translate
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            ListTile(
              title: TextField(
                controller: fpasServerURLController,
                decoration: InputDecoration(
                  // @todo translate settings_foss_public_alert_server_enter_url_label_text
                  labelText: 'Enter FPAS Server URL',
                  // settings_foss_public_alert_server_enter_url_error
                  errorText: _fpasServerURLError ? "Invalid Server URL" : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _fpasServerURLError = false;
                  });
                },
                onSubmitted: (newUrl) async {
                  try {
                    await fetchFPASServerSettings(newUrl);
                    setState(() {
                      _fpasServerURLError = false;
                    });
                  } catch (e) {
                    debugPrint(e.toString());
                    setState(() {
                      _fpasServerURLError = true;
                    });
                  }
                },
              ),
            ),
            userPreferences.fossPublicAlertServerOperator != ""
                ? ListTile(
                    leading: Icon(Icons.account_balance),
                    title: Text(
                        "Server Operator: ${userPreferences.fossPublicAlertServerOperator}"),
                  )
                : SizedBox(),
            userPreferences.fossPublicAlertServerTermsOfService != ""
                ? ListTile(
                    leading: Icon(Icons.open_in_new),
                    title: Text("Server Terms of Service"),
                    onTap: () {
                      launchUrlInBrowser(
                          userPreferences.fossPublicAlertServerTermsOfService);
                    },
                  )
                : SizedBox(),
            userPreferences.fossPublicAlertServerPrivacyNotice != ""
                ? ListTile(
                    leading: Icon(Icons.open_in_new),
                    title: Text("Server Privacy"),
                    onTap: () {
                      launchUrlInBrowser(
                          userPreferences.fossPublicAlertServerPrivacyNotice);
                    },
                  )
                : SizedBox(),
            Divider(
              height: 50,
              indent: 15.0,
              endIndent: 15.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: indentOfCategoriesTitles),
              child: Text(
                AppLocalizations.of(context)!.settings_display,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_start_view),
              trailing: DropdownButton<int>(
                value: userPreferences.startScreen,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                underline: Container(
                  height: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onChanged: (int? newValue) {
                  setState(() {
                    userPreferences.startScreen = newValue!;
                  });
                },
                items: [0, 1].map<DropdownMenuItem<int>>((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(startViewLabels[value]!),
                  );
                }).toList(),
              ),
            ),
            ListTile(
                title: Text(AppLocalizations.of(context)!
                    .settings_show_extended_metadata),
                trailing: Switch(
                    value: userPreferences.showExtendedMetaData,
                    onChanged: (value) {
                      setState(() {
                        userPreferences.showExtendedMetaData = value;
                      });
                    })),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_color_schema),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ChooseThemeDialog();
                  },
                );
              },
            ),
            /* ListTile(
              title: Text(AppLocalizations.of(context)!
                  .settings_display_all_warnings_title),
              subtitle: Text(AppLocalizations.of(context)!
                  .settings_display_all_warnings_subtitle),
              trailing: Switch(
                  value: userPreferences.showAllWarnings,
                  onChanged: (value) {
                    setState(() {
                      userPreferences.showAllWarnings = value;
                    });
                    saveSettings();
                    final updater = Provider.of<Update>(context, listen: false);
                    updater.updateView();
                  }),
            ), */
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_font_size),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FontSizeDialog();
                  },
                );
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_sorting),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SortByDialog();
                  },
                );
              },
            ),
            Divider(
              height: 50,
              indent: 15.0,
              endIndent: 15.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: indentOfCategoriesTitles),
              child: Text(
                AppLocalizations.of(context)!.settings_extended_settings,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            ListTile(
              title: Text(
                  (AppLocalizations.of(context)!.settings_show_welcome_dialog)),
              onTap: () {
                // TODO(PureTryOut): replace for go_router
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IntroductionView(),
                  ),
                );
              },
            ),
            ListTile(
              title:
                  Text((AppLocalizations.of(context)!.settings_dev_settings)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DevSettings()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openNotificationSettings() async {
    try {
      await _platform.invokeMethod("openNotificationSettings");
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }
}
