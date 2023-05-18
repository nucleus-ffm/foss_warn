import 'package:foss_warn/class/class_Geocode.dart';

import '../class/class_Area.dart';

List<Area> areaListFromJson(var data) {
  List<Area> result = [];
  for (int i = 0; i < data.length; i++) {
    result.add(Area.fromJson(data[i]));
  }
  return result;
}

List<Geocode> geocodeListFromJson(var data) {
  List<Geocode> result = [];
  for (int i = 0; i < data.length; i++) {
    result.add(Geocode.fromJson(data[i]));
  }
  return result;
}
