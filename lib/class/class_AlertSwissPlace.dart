import 'dart:convert';

import 'abstract_Place.dart';
import 'class_WarnMessage.dart';

class AlertSwissPlace extends Place {
  final String _shortName;

  String get shortName => _shortName;

  AlertSwissPlace({required String shortName, required String name})
      : _shortName = shortName, super(name: name, warnings: []);

  AlertSwissPlace.withWarnings(
      {required String shortName,
      required String name,
      required List<WarnMessage> warnings})
      : _shortName = shortName, super(name: name, warnings: warnings);

  factory AlertSwissPlace.fromJson(Map<String, dynamic> json) {

    /// create new warnMessage objects from saved data
    List<WarnMessage> createWarningList(String data) {
      List<dynamic> _jsonData = jsonDecode(data);
      List<WarnMessage> result = [];
      for (int i = 0; i < _jsonData.length; i++) {
        result.add(WarnMessage.fromJson(_jsonData[i]));
      }
      return result;
    }

    return AlertSwissPlace.withWarnings(
        name: json['name'] as String,
        shortName: json['shortName'] as String,
        warnings: createWarningList(json['warnings']));
  }

  @override
  Map<String, dynamic> toJson() =>
      {'name': name, 'shortName': shortName, 'warnings': jsonEncode(warnings)};
}
