import 'class_WarnMessage.dart';

class Place {
  String name;
  String geocode;
  dynamic countWarnings = 0;
  List<WarnMessage> warnings = [];
  List<WarnMessage> alreadyReadWarnings = [];

  Place( {required this.name, required this.geocode});

  Place.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        geocode = json['geocode'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'geocode': geocode,
  };
}