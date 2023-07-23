import 'package:foss_warn/class/class_Geocode.dart';
import 'package:foss_warn/class/abstract_Place.dart';

import 'class_WarnMessage.dart';

class NinaPlace extends Place {
  final Geocode _geocode;

  NinaPlace({
    required Geocode geocode,
    required String name,
  })  : _geocode = geocode,
        super(name: name, warnings: []);

  /// returns the name of the place with the state
  @override
  String get name => "${super.name}, ${_geocode.stateName}";
  Geocode get geocode => _geocode;

  NinaPlace.withWarnings(
      {required Geocode geocode,
      required String name,
      required List<WarnMessage> warnings})
      : _geocode = geocode,
        super(name: name, warnings: warnings);

  factory NinaPlace.fromJson(Map<String, dynamic> json) {
    List<WarnMessage> createWarningList(var data) {
      List<WarnMessage> result = [];
      for (int i = 0; i < data.length; i++) {
        result.add(WarnMessage.fromJson(data[i]));
      }
      return result;
    }

    return NinaPlace.withWarnings(
      name: json['name'] as String,
      geocode: Geocode.fromJson(json['geocode']),
      warnings: createWarningList(json['warnings']),
    );
  }

  Map<String, dynamic> toJson() =>
      {'name': name, 'geocode': geocode, 'warnings': warnings};
}
