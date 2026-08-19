import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foss_warn/extensions/context.dart';

/// collect all available infos to help finding Bugs and wrong settings
Future<String> collectSystemInfo(BuildContext context) async {
  var localizations = context.localizations;
  String result = localizations.collect_system_information_system_information;
  result += "\n\n";
  result +=
      "${localizations.collect_system_information_battery_optimization}: ${await _isBatteryOptimizationEnabled()} \n";
  return result;
}

Future<bool> _isBatteryOptimizationEnabled() async {
  const platform = MethodChannel('flutter.native/helper');
  try {
    return await platform.invokeMethod("isBatteryOptimizationEnabled");
  } on PlatformException catch (e) {
    debugPrint("$e");
    return false;
  }
}
