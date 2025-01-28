import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_geocode.dart';
import 'package:foss_warn/class/abstract_place.dart';

import 'class_error_logger.dart';
import 'class_warn_message.dart';

class NinaPlace extends Place {
  final Geocode _geocode;

  NinaPlace({
    required Geocode geocode,
    required super.name,
    super.eTag = "",
  })  : _geocode = geocode,
        super(warnings: []);

  /// returns the name of the place with the state
  @override
  String get name => "${super.name} (${_geocode.stateName})";

  String get nameWithoutState => super.name;

  Geocode get geocode => _geocode;

  NinaPlace.withWarnings(
      {required Geocode geocode,
      required super.name,
      required super.warnings,
      required super.eTag})
      : _geocode = geocode;

  factory NinaPlace.fromJson(Map<String, dynamic> json) {
    /// create new warnMessage objects from saved data
    List<WarnMessage> createWarningList(String data) {
      List<dynamic> jsonData = jsonDecode(data);
      List<WarnMessage> result = [];
      for (int i = 0; i < jsonData.length; i++) {
        result.add(WarnMessage.fromJson(jsonData[i]));
      }
      return result;
    }

    return NinaPlace.withWarnings(
      name: json['name'] as String,
      geocode: Geocode.fromJson(json['geocode']),
      warnings: createWarningList(json['warnings']),
      eTag: (json['eTag'] ?? "") as String,
    );
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'name': nameWithoutState,
        'geocode': geocode,
        'warnings': jsonEncode(warnings),
        'eTag': eTag
      };
    } catch (e) {
      debugPrint("Error nina place to json: $e");
      ErrorLogger.writeErrorLog(
          "class_NinaPlace.dart", "Can not serialize nina place", e.toString());
      return {};
    }
  }
}
