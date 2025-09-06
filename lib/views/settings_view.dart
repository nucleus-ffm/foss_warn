import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/extensions/context.dart';

import '../main.dart';
import '../services/url_launcher.dart';
import '../widgets/dialogs/choose_theme_dialog.dart';

import '../widgets/dialogs/font_size_dialog.dart';
import '../widgets/dialogs/sort_by_dialog.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({
    required this.onNotificationSettingsPressed,
    required this.onIntroductionPressed,
    required this.onDevSettingsPressed,
    super.key,
  });

  final VoidCallback onNotificationSettingsPressed;
  final VoidCallback onIntroductionPressed;
  final VoidCallback onDevSettingsPressed;

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
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
    var localizations = context.localizations;
    var theme = Theme.of(context);

    const double indentOfCategoriesTitles = 15;

    final Map<int, String> startViewLabels = {
      0: localizations.settings_start_view_all_warnings,
      1: localizations.settings_start_view_only_my_places,
    };

    var alertApi = ref.read(alertApiProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: indentOfCategoriesTitles,
                top: indentOfCategoriesTitles,
              ),
              child: Text(
                localizations.settings_notification,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            ListTile(
              title: Text(localizations.settings_android_notification_settings),
              onTap: () => _openNotificationSettings(),
            ),
            ListTile(
              title: Text(localizations.settings_app_notification_settings),
              onTap: widget.onNotificationSettingsPressed,
            ),
            const Divider(
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
                  color: theme.colorScheme.primary,
                ),
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
                    var serverSettings =
                        await alertApi.fetchServerSettings(overrideUrl: newUrl);
                    userPreferences.fossPublicAlertServerUrl =
                        serverSettings.url;
                    userPreferences.fossPublicAlertServerOperator =
                        serverSettings.operator;
                    userPreferences.fossPublicAlertServerPrivacyNotice =
                        serverSettings.privacyNotice;
                    userPreferences.fossPublicAlertServerTermsOfService =
                        serverSettings.termsOfService;
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
                    leading: const Icon(Icons.account_balance),
                    title: Text(
                      "Server Operator: ${userPreferences.fossPublicAlertServerOperator}",
                    ),
                  )
                : const SizedBox(),
            userPreferences.fossPublicAlertServerTermsOfService != ""
                ? ListTile(
                    leading: const Icon(Icons.open_in_new),
                    title: const Text("Server Terms of Service"),
                    onTap: () {
                      launchUrlInBrowser(
                        userPreferences.fossPublicAlertServerTermsOfService,
                      );
                    },
                  )
                : const SizedBox(),
            userPreferences.fossPublicAlertServerPrivacyNotice != ""
                ? ListTile(
                    leading: const Icon(Icons.open_in_new),
                    title: const Text("Server Privacy"),
                    onTap: () {
                      launchUrlInBrowser(
                        userPreferences.fossPublicAlertServerPrivacyNotice,
                      );
                    },
                  )
                : const SizedBox(),
            const Divider(
              height: 50,
              indent: 15.0,
              endIndent: 15.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: indentOfCategoriesTitles),
              child: Text(
                localizations.settings_display,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ListTile(
              title: Text(localizations.settings_start_view),
              trailing: DropdownButton<int>(
                value: userPreferences.startScreen,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: theme.colorScheme.primary),
                underline: Container(
                  height: 2,
                  color: theme.colorScheme.primary,
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
              title: Text(localizations.settings_show_extended_metadata),
              trailing: Switch(
                value: userPreferences.showExtendedMetaData,
                onChanged: (value) {
                  setState(() {
                    userPreferences.showExtendedMetaData = value;
                  });
                },
              ),
            ),
            ListTile(
              title: Text(localizations.settings_color_schema),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const ChooseThemeDialog();
                  },
                );
              },
            ),
            ListTile(
              title: Text(localizations.settings_font_size),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const FontSizeDialog();
                  },
                );
              },
            ),
            ListTile(
              title: Text(localizations.settings_sorting),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const SortByDialog();
                  },
                );
              },
            ),
            const Divider(
              height: 50,
              indent: 15.0,
              endIndent: 15.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: indentOfCategoriesTitles),
              child: Text(
                localizations.settings_extended_settings,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ListTile(
              title: Text((localizations.settings_show_welcome_dialog)),
              onTap: widget.onIntroductionPressed,
            ),
            ListTile(
              title: Text(localizations.settings_dev_settings),
              onTap: widget.onDevSettingsPressed,
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
