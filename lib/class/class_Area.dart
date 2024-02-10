import 'dart:convert';

import 'package:latlong2/latlong.dart';

import 'class_Geocode.dart';

class Area {
  String description; // Kreisname
  List<LatLng> polygon;
  Geocode geocode; // currently only used by alert siwss


  Area({required String areaDesc, required Geocode geocode, required polygon})
      : this.description = areaDesc,
        this.geocode = geocode,
          this.polygon = _polygonFromJson(polygon)
  ;

  Area.fromJson(Map<String, dynamic> json)
      : description = json['areaDesc'],
        geocode = Geocode.fromJson(json['geocode']),
        polygon = _polygonFromJson(jsonDecode(json['polygon']));

  Area.fromJsonTemp(Map<String, dynamic> json, List<dynamic> coordinates)
      : description = json['areaDesc'],
        geocode =  Geocode(geocodeName: "", geocodeNumber: "", PLZ: "-1" , longitude: "-1", latitude: "-1") , // The API only ever provides the information "valueName: "AreaID, value: "0" "
        polygon = _polygonFromJsonTemp(coordinates);

  static List<LatLng> _polygonFromJson(List<dynamic> data) {
    List<LatLng> result = [];
    for (int i= 0; i<data.length; i++) {
      //print(data[i]);
      result.add(LatLng(data[i]["coordinates"][1], data[i]["coordinates"][0]));
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
        'areaDesc': description,
        'geocode': geocode,
        'polygon' : jsonEncode(polygon)
      };

  static List<LatLng> _polygonFromJsonTemp(List<dynamic> data) {
    List<LatLng> result = [];
    for (int i= 0; i<data.length; i++) {
      result.add(LatLng(data[i][1].toDouble(), data[i][0].toDouble()) );
    }
    return result;
  }

  static List<Area> areaListFromJson(var data) {
    List<Area> _result = [];
    if(data != null) {
      for (int i = 0; i < data.length; i++) {
        _result.add(Area.fromJson(data[i]));
      }
    }
    return _result;
  }

  static List<Area> areaListFromJsonTemp(var data, List<dynamic> coordinates) {
    List<Area> _result = [];
    if(data != null) {
      for (int i = 0; i < data.length; i++) {
        _result.add(Area.fromJsonTemp(data[i], coordinates));
      }
    }
    return _result;
  }
}
