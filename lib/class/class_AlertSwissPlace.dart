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
    List<WarnMessage> createWarningList(var data) {
      List<WarnMessage> result = [];
      for (int i = 0; i < data.length; i++) {
        result.add(WarnMessage.fromJson(data[i]));
      }
      return result;
    }

    return AlertSwissPlace.withWarnings(
        name: json['name'] as String,
        shortName: json['shortName'] as String,
        warnings: createWarningList(json['warnings']));
  }

  Map<String, dynamic> toJson() =>
      {'name': name, 'shortName': shortName, 'warnings': warnings};
}
