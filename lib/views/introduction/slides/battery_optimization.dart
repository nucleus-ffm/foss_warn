import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/views/introduction/widgets/base_slide.dart';
import 'package:foss_warn/views/introduction/widgets/checkmark.dart';

/// invoke android platform specific method to check if battery optimization
/// is currently enabled
Future<bool> _isBatteryOptimizationEnabled() async {
  const platformMethodChannel = MethodChannel("flutter.native/helper");

  try {
    return await platformMethodChannel
        .invokeMethod("isBatteryOptimizationEnabled");
  } on PlatformException {
    return false;
  }
}

class IntroductionBatteryOptimizationSlide extends StatefulWidget {
  const IntroductionBatteryOptimizationSlide({super.key});

  @override
  State<IntroductionBatteryOptimizationSlide> createState() =>
      _IntroductionBatteryOptimizationSlideState();
}

class _IntroductionBatteryOptimizationSlideState
    extends State<IntroductionBatteryOptimizationSlide>
    with WidgetsBindingObserver {
  late Future<bool> isBatteryOptimizationEnabled;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    isBatteryOptimizationEnabled = _isBatteryOptimizationEnabled();

    setState(() {});

    super.initState();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!mounted) return;

    if (state == AppLifecycleState.resumed) {
      isBatteryOptimizationEnabled = _isBatteryOptimizationEnabled();

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var theme = Theme.of(context);

    Future<void> onShowBatteryOptimizationDialogPressed() async {
      const platformMethodChannel = MethodChannel("flutter.native/helper");

      await platformMethodChannel
          .invokeMethod("showIgnoreBatteryOptimizationDialog");
    }

    return IntroductionBaseSlide(
      imagePath: "assets/battery.png",
      title: localizations.welcome_view_battery_optimisation_headline,
      text: localizations.welcome_view_battery_optimisation_text,
      footer: FutureBuilder(
        future: isBatteryOptimizationEnabled,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text(
              localizations.welcome_view_battery_optimisation_verifying,
            );
          }

          var batteryOptimizationEnabled = snapshot.data ?? false;

          if (!batteryOptimizationEnabled) {
            return const IntroductionCheckmark();
          }

          return Column(
            children: [
              TextButton(
                onPressed: () => onShowBatteryOptimizationDialogPressed(),
                style: TextButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                ),
                child: Text(
                  localizations.welcome_view_battery_optimisation_action,
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
