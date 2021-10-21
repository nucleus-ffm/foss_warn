import 'class_WarnMessage.dart';

class Place {
  String name;
  dynamic countWarnings = 0;
  List<WarnMessage> warnings = [];
  List<WarnMessage> alreadyReadWarnings = [];

  Place( {required this.name});
}