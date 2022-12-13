import 'package:flutter/services.dart';

/// collect all available infos to help finding Bugs and wrong settings
Future<String> collectSystemInfo() async {
  final _platform = const MethodChannel('flutter.native/helper');
  String result  = "Systeminformationen \n \n";

  result+= "Akkuoptimierung: "  + (await _platform.invokeMethod("isBatteryOptimizationEnabled")).toString() + "\n ";

  return result;
}