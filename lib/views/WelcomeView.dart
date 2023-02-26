import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/welcomeScreenItems.dart';
import '../main.dart';
import 'SettingsView.dart';
import '../services/saveAndLoadSharedPreferences.dart';
import '../widgets/dialogs/DisclaimerDialog.dart';
import '../widgets/dialogs/privacyDialog.dart';
import 'addMyPlaceView.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  _WelcomeViewState createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> with WidgetsBindingObserver {
  final _platform = const MethodChannel("flutter.native/helper");
  late Future<bool> _batteryOptimizationFuture;
  List<WelcomeScreenItem>? _welcomeScreenItems;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      _batteryOptimizationFuture = this._isBatteryOptimizationEnabled();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _batteryOptimizationFuture = this._isBatteryOptimizationEnabled();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_welcomeScreenItems == null) {
      _welcomeScreenItems = getWelcomeScreenItems(context);
    }

    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _welcomeScreenItems!.length,
              itemBuilder: (BuildContext context, int index) {
                final WelcomeScreenItem item = _welcomeScreenItems![index];
                final isLastSlide = index == _welcomeScreenItems!.length - 1;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: _buildSlide(item)),
                    _buildActionButtons(context, item.action),
                    isLastSlide
                        ? SizedBox(height: 90)
                        : Container(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: _buildStepsIndicator(index))
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(WelcomeScreenItem item) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(item.imagePath, width: 220.0, height: 200.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Text(item.title,
                      style: TextStyle(fontSize: 34.0, height: 2.0)),
                  SingleChildScrollView(
                    child: Text(
                      item.description,
                      style: TextStyle(
                          color: Colors.grey,
                          letterSpacing: 1.2,
                          fontSize: 16.0,
                          height: 1.3),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }

  Widget _buildActionButtons(BuildContext context, String? action) {
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
                      return FilledButton.icon(
                        onPressed: batteryOptimizationEnabled
                            ? () => _showIgnoreBatteryOptimizationDialog()
                            : null,
                        label: Text(
                          batteryOptimizationEnabled
                              ? AppLocalizations.of(context)
                                  .welcome_view_battery_optimisation_action
                              : AppLocalizations.of(context)
                                  .welcome_view_battery_optimisation_action_success,
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: batteryOptimizationEnabled
                            ? Icon(Icons.battery_saver)
                            : Icon(Icons.check),
                      );
                    } else {
                      print(
                          "Error getting battery optimization status: ${snapshot.error}");
                      return Text("Error", style: TextStyle(color: Colors.red));
                    }
                  } else
                    return CircularProgressIndicator();
                })
          ],
        );
      case "setup":
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMyPlaceView()),
                )
              },
              child: Text(
                "Setup a place",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        );
      case "disclaimer":
        return Column(
          children: [
            FilledButton(
              onPressed: () {
                showDialog(
                  context: navigatorKey.currentContext!,
                  builder: (BuildContext context) => DisclaimerDialog(),
                );
              },
              child: Text(
                AppLocalizations.of(context).about_disclaimer,
                style: TextStyle(color: Colors.white),
              ),
            ),
            FilledButton(
                onPressed: () {
                  showDialog(
                    context: navigatorKey.currentContext!,
                    builder: (BuildContext context) => PrivacyDialog(),
                  );
                },
                child: Text(
                  AppLocalizations.of(context).about_privacy,
                  style: TextStyle(color: Colors.white),
                )),
          ],
        );
      case "end":
        return FilledButton(
            onPressed: () {
              setState(() {
                showWelcomeScreen = false;
              });
              saveSettings();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => HomeView(),
                ),
              );
            },
            child: Text(
              AppLocalizations.of(context).welcome_view_end_button,
              style: TextStyle(color: Colors.white),
            ));
      default:
        return SizedBox(height: 80);
    }
  }

  Widget _buildStepsIndicator(int currentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          _welcomeScreenItems!.length,
          (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 3.0),
                height: 10.0,
                width: 10.0,
                decoration: BoxDecoration(
                    color: currentPage.round() == index
                        ? Color(0XFF256075)
                        : Color(0XFF256075).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0)),
              )),
    );
  }

  Future<void> _showIgnoreBatteryOptimizationDialog() async {
    try {
      await _platform.invokeMethod("showIgnoreBatteryOptimizationDialog");
    } on PlatformException catch (e) {
      print(e);
    }

    // reloading the battery optimization status happens in _WelcomeViewState#didChangeAppLifecycleState
  }

  Future<bool> _isBatteryOptimizationEnabled() async {
    try {
      return await _platform.invokeMethod("isBatteryOptimizationEnabled");
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }
}
