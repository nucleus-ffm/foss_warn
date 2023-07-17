import 'package:foss_warn/class/class_Geocode.dart';

import '../class/class_Area.dart';

List<Area> areaListFromJson(var data) {
  List<Area> _result = [];
  for (int i = 0; i < data.length; i++) {
    _result.add(Area.fromJson(data[i]));
  }
  return _result;
}

List<Geocode> geocodeListFromJson(var data) {
  List<Geocode> _result = [];
  for (int i = 0; i < data.length; i++) {
    _result.add(Geocode.fromJson(data[i]));
  }
  return _result;
}
