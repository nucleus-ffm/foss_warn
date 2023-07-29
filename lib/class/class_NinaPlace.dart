import 'dart:convert';
import 'package:foss_warn/class/class_Geocode.dart';
import 'package:foss_warn/class/abstract_Place.dart';

import 'class_WarnMessage.dart';

class NinaPlace extends Place {
  final Geocode _geocode;

  NinaPlace({
    required Geocode geocode,
    required String name,
    String eTag = "",
  })  : _geocode = geocode,
        super(name: name, warnings: [], eTag: eTag);

  /// returns the name of the place with the state
  @override
  String get name => "${super.name}, (${_geocode.stateName})";

  String get nameWithoutState => super.name;

  Geocode get geocode => _geocode;

  NinaPlace.withWarnings(
      {required Geocode geocode,
      required String name,
      required List<WarnMessage> warnings,
      required String eTag})
      : _geocode = geocode,
        super(name: name, warnings: warnings, eTag: eTag);

  factory NinaPlace.fromJson(Map<String, dynamic> json) {

    /// create new warnMessage objects from saved data
    List<WarnMessage> createWarningList(String data) {
      List<dynamic> _jsonData = jsonDecode(data);
      List<WarnMessage> result = [];
        for (int i = 0; i < _jsonData.length; i++) {
          result.add(WarnMessage.fromJson(_jsonData[i]));
        }
      return result;
    }

    return NinaPlace.withWarnings(
      name: json['name'] as String,
      geocode: Geocode.fromJson(json['geocode']),
      warnings: createWarningList(json['warnings']),
      eTag:  (json['eTag'] ?? "") as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    try {
      return {'name': nameWithoutState, 'geocode': geocode, 'warnings': jsonEncode(warnings), 'eTag': eTag
      };
    } catch (e) {
      print("Error nina place to json: " + e.toString());
      return {};
    }
  }
}
