import 'dart:convert';

import 'abstract_place.dart';
import 'class_warn_message.dart';

class AlertSwissPlace extends Place {
  final String _shortName;

  String get shortName => _shortName;

  AlertSwissPlace(
      {required String shortName, required super.name, super.eTag = ""})
      : _shortName = shortName,
        super(warnings: []);

  AlertSwissPlace.withWarnings({
    required String shortName,
    required super.name,
    required super.warnings,
    required super.eTag,
  }) : _shortName = shortName;

  factory AlertSwissPlace.fromJson(Map<String, dynamic> json) {
    /// create new warnMessage objects from saved data
    List<WarnMessage> createWarningList(String data) {
      List<dynamic> jsonData = jsonDecode(data);
      List<WarnMessage> result = [];
      for (int i = 0; i < jsonData.length; i++) {
        result.add(WarnMessage.fromJson(jsonData[i]));
      }
      return result;
    }

    return AlertSwissPlace.withWarnings(
        name: json['name'] as String,
        shortName: json['shortName'] as String,
        warnings: createWarningList(json['warnings']),
        eTag: "");
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'shortName': shortName,
        'warnings': jsonEncode(warnings),
        'eTag': eTag
      };
}
