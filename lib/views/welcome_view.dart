import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../class/class_fpas_place.dart';
import '../class/class_notification_service.dart';
import '../services/url_launcher.dart';
import '../services/welcome_screen_items.dart';
import '../main.dart';
import '../widgets/dialogs/disclaimer_dialog.dart';
import '../widgets/dialogs/privacy_dialog.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> with WidgetsBindingObserver {
  double _currentPage = 0.0;
  final _pageViewController = PageController();
  final _platform = const MethodChannel("flutter.native/helper");
  late Future<bool> _batteryOptimizationFuture;
  bool notificationPermission = false;
  bool exactAlarmPermission = false;
  final TextEditingController _fpasTextController = TextEditingController();
  bool _fpasServerURLError = false;
  bool _fpasServerSettingsConfirmed = false;
  int useDefaultServerOptionCurrentValue = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      _batteryOptimizationFuture = _isBatteryOptimizationEnabled();
      _fpasTextController.text = userPreferences.fossPublicAlertServerUrl;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fpasTextController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _batteryOptimizationFuture = _isBatteryOptimizationEnabled();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _pageViewController.addListener(() {
      setState(() {
        _currentPage = _pageViewController.page!;
      });
    });
    final isLastSlide =
        _currentPage == getWelcomeScreenItems(context).length - 1;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.horizontal,
            controller: _pageViewController,
            itemCount: getWelcomeScreenItems(context).length,
            itemBuilder: (BuildContext context, int index) =>
                _buildSlide(index),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(top: 70.0),
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: isLastSlide
                    ? TextButton(
                        onPressed: () {

                          setState(() {
                            userPreferences.showWelcomeScreen = false;
                          });

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => HomeView(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary),
                        child: Text(
                          AppLocalizations.of(context)!.welcome_view_end_button,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
                        ))
                    : _buildStepsIndicator(),
              ))
        ],
      ),
    );
  }

  Widget _buildSlide(int index) {
    WelcomeScreenItem item = getWelcomeScreenItems(context)[index];
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.fitWidth,
                width: 220.0,
                height: 200.0,
                alignment: Alignment.bottomCenter,
              ),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(item.title,
                          style: TextStyle(
                              fontSize: 29.0,
                              fontWeight: FontWeight.w300,
                              height: 2.0)),
                      Text(
                        item.description,
                        style: TextStyle(
                            color: Colors.grey,
                            letterSpacing: 1.2,
                            fontSize: 16.0,
                            height: 1.3),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      _buildActionButtons(item.action)
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }

  Widget _buildActionButtons(String? action) {
    final Map<int, String> useDefaultServerOptions = {
      // welcome_view_foss_public_alert_server_use_default_server
      0: "Use default server (${userPreferences.fossPublicAlertServerUrlDefault})",
      // welcome_view_foss_public_alert_server_use_custom_server
      1: "Use custom server"  
    };

    switch (action) {
      case "batteryOptimization":
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<bool>(
                future: _batteryOptimizationFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      final bool batteryOptimizationEnabled = snapshot.data!;
                      return batteryOptimizationEnabled
                          ? TextButton(
                              onPressed: () =>
                                  _showIgnoreBatteryOptimizationDialog(),
                              style: TextButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .welcome_view_battery_optimisation_action,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                            )
                          : Column(
                              children: [
                                Icon(
                                  Icons.check,
                                  size: 56,
                                  color: Colors.green,
                                ),
                                Text(
                                  AppLocalizations.of(context)!
                                      .welcome_view_battery_optimisation_action_success,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      letterSpacing: 1.2,
                                      fontSize: 16.0,
                                      height: 1.3),
                                )
                              ],
                            );
                    } else {
                      debugPrint(
                          "Error getting battery optimization status: ${snapshot.error}");
                      return Text("Error", style: TextStyle(color: Colors.red));
                    }
                  } else {
                    return CircularProgressIndicator();
                  }
                })
          ],
        );
      case "disclaimer":
        return Column(
          children: [
            TextButton(
              onPressed: () {
                showDialog(
                  context: navigatorKey.currentContext!,
                  builder: (BuildContext context) => DisclaimerDialog(),
                );
              },
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary),
              child: Text(
                AppLocalizations.of(context)!.about_disclaimer,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: navigatorKey.currentContext!,
                  builder: (BuildContext context) => PrivacyDialog(),
                );
              },
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary),
              child: Text(
                AppLocalizations.of(context)!.about_privacy,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          ],
        );
      case "ask_permission_notification":
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            notificationPermission
                ? Column(
                    children: [
                      Icon(
                        Icons.check,
                        size: 56,
                        color: Colors.green,
                      ),
                      Text(
                        AppLocalizations.of(context)!
                            .welcome_view_battery_optimisation_action_success,
                        style: TextStyle(
                            color: Colors.grey,
                            letterSpacing: 1.2,
                            fontSize: 16.0,
                            height: 1.3),
                      )
                    ],
                  )
                : TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: () async {
                      bool temp = await NotificationService()
                              .requestNotificationPermission() ??
                          false;
                      setState(() {
                        notificationPermission = temp;
                      });
                      // init the notification service here as we have not done
                      // this in main due to the welcome view
                      await NotificationService().init();
                    },
                    child: Text(
                      "Request permission",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  )
          ],
        );
      case 'ask_permission_exact_alarm':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            exactAlarmPermission
                ? Column(
                    children: [
                      Icon(
                        Icons.check,
                        size: 56,
                        color: Colors.green,
                      ),
                      Text(
                        AppLocalizations.of(context)!
                            .welcome_view_battery_optimisation_action_success,
                        style: TextStyle(
                            color: Colors.grey,
                            letterSpacing: 1.2,
                            fontSize: 16.0,
                            height: 1.3),
                      )
                    ],
                  )
                : TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: () async {
                      bool temp = await NotificationService()
                              .requestExactAlarmPermission() ??
                          false;
                      setState(() {
                        exactAlarmPermission = temp;
                      });
                    },
                    child: Text(
                      "Request permission", // welcome_view_request_permission
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  )
          ],
        );
      case 'FPAS':
        return Column(
          children: [
            // welcome_view_foss_public_alert_server_select_instance
            Text(
              "Select FPAS Server instance",
              style: TextStyle(fontSize: 17),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.open_in_browser),
                Flexible(
                  fit: FlexFit.loose,
                  child: TextButton(
                      onPressed: () => launchUrlInBrowser(
                          'https://github.com/nucleus-ffm/foss_warn/wiki/What-is-the-FOSS-Public-Alert-Server-and-why-do-I-have-to-select-a-server%3F'),
                      child: Text(//@todo translation
                          // welcome_view_foss_public_alert_server_select_instance_helptext
                          "Why do I need to select a server?")),
                ),
              ],
            ),
            // show drop down to select between default server and custom url
            DropdownButtonFormField<int>(
              value: useDefaultServerOptionCurrentValue,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
              onChanged: (int? newValue) {
                setState(() {
                  useDefaultServerOptionCurrentValue = newValue ?? 0;
                });
              },
              items: [0, 1].map<DropdownMenuItem<int>>((value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(useDefaultServerOptions[value]!),
                );
              }).toList(),
            ),
            SizedBox(
              height: 10,
            ),
            // let the user confirm the default server to fetch the server settings
            // if the user does not do that, we can not display the privacy
            // police and the ToS of the server instance
            useDefaultServerOptionCurrentValue == 0
                ? _fpasServerSettingsConfirmed
                    ? Text(
                        "Confirmed") // welcome_view_foss_public_alert_server_confirm_success
                    : TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary),
                        onPressed: () async {
                          bool fetchSuccessful =
                              await FPASPlace.fetchServerSettings(
                                  userPreferences
                                      .fossPublicAlertServerUrlDefault);
                          setState(() {
                            _fpasServerURLError = !fetchSuccessful;
                            _fpasServerSettingsConfirmed = true;
                          });
                        },
                        child: Text(
                          // welcome_view_foss_public_alert_server_confirm_button
                          "Confirm and load settings",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      )
                : SizedBox(
                    height: 10,
                  ),
            useDefaultServerOptionCurrentValue == 1
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _fpasTextController,
                          decoration: InputDecoration(
                            // settings_foss_public_alert_server_enter_url_label_text
                            labelText: 'Enter FPAS Server URL',
                            // settings_foss_public_alert_server_enter_url_error
                            errorText: _fpasServerURLError
                                ? "Invalid Server URL"
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _fpasServerURLError = false;
                            });
                          },
                          onSubmitted: (newUrl) async {
                            bool fetchSuccessful =
                                await FPASPlace.fetchServerSettings(newUrl);
                            setState(() {
                              _fpasServerURLError = !fetchSuccessful;
                              _fpasServerSettingsConfirmed = false;
                            });
                          },
                        ),
                      ),
                      TextButton(
                          onPressed: () async {
                            bool fetchSuccessful =
                                await FPASPlace.fetchServerSettings(
                                    _fpasTextController.text);
                            setState(() {
                              _fpasServerURLError = !fetchSuccessful;
                              _fpasServerSettingsConfirmed = false;
                            });
                            // unset focus to hide the keyboard again
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: Text(
                              AppLocalizations.of(context)!.main_dialog_save))
                    ],
                  )
                : SizedBox(),
            userPreferences.fossPublicAlertServerOperator != ""
                ? Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                        // welcome_view_foss_public_alert_server_server_operator
                        "This server is operated by: "
                            "${userPreferences.fossPublicAlertServerOperator}"),
                  )
                : SizedBox(),
          ],
        );
      default:
        return SizedBox(height: 50);
    }
  }

  Widget _buildStepsIndicator() {
    return Visibility(
      // hide the step indicator if the keyboard is open
      visible: MediaQuery.of(context).viewInsets.bottom == 0 ? true : false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
            getWelcomeScreenItems(context).length,
            (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 3.0),
                  height: 10.0,
                  width: 10.0,
                  decoration: BoxDecoration(
                      color: _currentPage.round() == index
                          ? Color(0XFF256075)
                          : Color(0XFF256075).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.0)),
                )),
      ),
    );
  }

  /// invoke the android platform specific method to open the dialog to disable
  /// the batter optimization
  Future<void> _showIgnoreBatteryOptimizationDialog() async {
    try {
      await _platform.invokeMethod("showIgnoreBatteryOptimizationDialog");
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
    // reloading the battery optimization status happens
    // in _WelcomeViewState#didChangeAppLifecycleState
  }

  /// invoke android platform specific method to check if battery optimization
  /// is currently enabled
  Future<bool> _isBatteryOptimizationEnabled() async {
    try {
      return await _platform.invokeMethod("isBatteryOptimizationEnabled");
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
