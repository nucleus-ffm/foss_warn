import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/welcomeScreenItems.dart';
import '../main.dart';
import '../services/saveAndLoadSharedPreferences.dart';
import '../widgets/dialogs/DisclaimerDialog.dart';
import '../widgets/dialogs/privacyDialog.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  _WelcomeViewState createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> with WidgetsBindingObserver {
  double _currentPage = 0.0;
  final _pageViewController = new PageController();
  final _platform = const MethodChannel("flutter.native/helper");
  late Future<bool> _batteryOptimizationFuture;

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
    _pageViewController.addListener(() {
      setState(() {
        _currentPage = _pageViewController.page!;
      });
    });
    final isLastSlide =
        _currentPage == getWelcomeScreenItems(context).length - 1;

    return Scaffold(
      body: Container(
        child: Stack(
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
                            saveSettings();

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => HomeView(),
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!
                                .welcome_view_end_button,
                            style: TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.blue))
                      : _buildStepsIndicator(),
                ))
          ],
        ),
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
                              fontSize: 34.0,
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
                              child: Text(
                                AppLocalizations.of(context)!
                                    .welcome_view_battery_optimisation_action,
                                style: TextStyle(color: Colors.white),
                              ),
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue),
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
                      print(
                          "Error getting battery optimization status: ${snapshot.error}");
                      return Text("Error", style: TextStyle(color: Colors.red));
                    }
                  } else
                    return CircularProgressIndicator();
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
              child: Text(
                AppLocalizations.of(context)!.about_disclaimer,
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.blue),
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: navigatorKey.currentContext!,
                  builder: (BuildContext context) => PrivacyDialog(),
                );
              },
              child: Text(
                AppLocalizations.of(context)!.about_privacy,
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        );
      default:
        return SizedBox(height: 50);
    }
  }

  Widget _buildStepsIndicator() {
    return Row(
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
