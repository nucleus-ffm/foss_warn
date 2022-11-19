import 'class_WarnMessage.dart';

class Place {
  String name;
  String geocode;
  int countWarnings = 0;
  List<WarnMessage> warnings = [];
  List<WarnMessage> alreadyReadWarnings = [];

  Place({required this.name, required this.geocode});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
        name: json['name'] as String,
        geocode: json['geocode'] as String
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'geocode': geocode,
  };
}
