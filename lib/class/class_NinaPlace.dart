import 'package:foss_warn/class/class_Geocode.dart';
import 'package:foss_warn/class/abstract_Place.dart';

import 'class_WarnMessage.dart';

class NinaPlace extends Place {
  Geocode geocode;

  NinaPlace(
      {required this.geocode, required String name, })
      : super(name: name, warnings: []);

  /// returns the name of the place wit the state addition
  @override
  String getName() {
    return "$name  ${geocode.stateName}";
  }

  NinaPlace.withWarnings(
      {required this.geocode, required String name, required List<WarnMessage> warnings})
      : super(name: name, warnings: warnings);

  factory NinaPlace.fromJson(Map<String, dynamic> json) {

    List<WarnMessage> createWarningList(var data) {
      List<WarnMessage> result = [];
      for(int i = 0; i < data.length; i++) {
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
