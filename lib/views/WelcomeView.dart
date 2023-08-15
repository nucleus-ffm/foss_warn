import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/widgets/dialogs/ConfirmDialog.dart';
import '../services/geocodeHandler.dart';
import '../services/listHandler.dart';
import '../services/welcomeScreenItems.dart';
import '../main.dart';
import '../services/saveAndLoadSharedPreferences.dart';
import '../widgets/dialogs/DisclaimerDialog.dart';
import '../widgets/dialogs/privacyDialog.dart';
import 'AddMyPlaceView.dart';

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

  void didChangeAppLifecycleState(AppLifecycleState state) {
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
        body: PageView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _welcomeScreenItems!.length,
      itemBuilder: (BuildContext context, int index) {
        final _item = _welcomeScreenItems![index];
        final _isLastSlide = (index == _welcomeScreenItems!.length - 1);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSlide(context, _item),
            _buildActionButtons(context, _item.action),
            _isLastSlide
                ? SizedBox(height: 90)
                : Container(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: _buildStepsIndicator(index))
          ],
        );
      },
    ));
  }

  Widget _buildSlide(BuildContext context, WelcomeScreenItem item) {
    return Expanded(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(height: MediaQuery.of(context).size.height / 5.5),
      Expanded(
        child: Image.asset(item.imagePath, width: 220.0, height: 170.0),
      ),
      Text(item.title, style: TextStyle(fontSize: 34.0, height: 2.0)),
      Flexible(
        fit: FlexFit.loose,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: SingleChildScrollView(
              child: Text(item.description,
                  style: TextStyle(
                      color: Colors.grey,
                      letterSpacing: 1.2,
                      fontSize: 16.0,
                      height: 1.3),
                  textAlign: TextAlign.center)),
        ),
      ),
    ]));
  }

  Widget _buildActionButtons(BuildContext context, String? action) {
    switch (action) {
      case "batteryOptimization":
        return FutureBuilder<bool>(
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
                      ),
                      icon: batteryOptimizationEnabled
                          ? Icon(Icons.battery_saver)
                          : Icon(Icons.check, color: Colors.green));
                } else {
                  print(
                      "Error getting battery optimization status: ${snapshot.error}");
                  return Text("Error", style: TextStyle(color: Colors.red));
                }
              } else
                return CircularProgressIndicator();
            });
      case "setup":
        if (myPlaceList.isEmpty) {
          return FilledButton(
              onPressed: () {
                if (geocodeMap.isEmpty) {
                  // @todo: translations
                  showDialog(
                    context: context,
                    builder: (context) => ConfirmDialog(
                        title: "Make API call?",
                        description:
                            "If you want to setup a place right now, the full list of places must be downloaded. Are you okay with using the API at this stage?",
                        actionText: "Agree",
                        onConfirmed: () {
                          print("call geocode handler");
                          geocodeHandler();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddMyPlaceView()),
                          );
                        }),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddMyPlaceView()),
                  );
                }
              },
              child: Text(
                  // @todo translations
                  "Setup a place"));
        } else {
          return FilledButton.icon(
              onPressed: null,
              icon: Icon(Icons.check, color: Colors.green),
              label: Text(myPlaceList.first.name));
        }
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
              ),
            ),
          ],
        );
      case "end":
        return FilledButton(
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
          (index) => Builder(builder: (context) {
                final bool isActive = index == currentPage;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  height: isActive ? 12 : 8,
                  width: isActive ? 12 : 8,
                  decoration: BoxDecoration(
                      color: isActive ? Colors.blue[700] : Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                );
              })),
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
