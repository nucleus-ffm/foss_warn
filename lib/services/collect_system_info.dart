import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// collect all available infos to help finding Bugs and wrong settings
Future<String> collectSystemInfo() async {
  String result = "Systeminformationen \n\n";

  result += "Akkuoptimierung: ${await _isBatteryOptimizationEnabled()} \n";

  return result;
}

Future<bool> _isBatteryOptimizationEnabled() async {
  final platform = const MethodChannel('flutter.native/helper');
  try {
    return await platform.invokeMethod("isBatteryOptimizationEnabled");
  } on PlatformException catch (e) {
    debugPrint("$e");
    return false;
  }
}
