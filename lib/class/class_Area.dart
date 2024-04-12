import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:latlong2/latlong.dart';

class Area {
  String description; // Kreisname or general description of the area
  String geoJson; // polygons of the area stored as pure json file
  String? region; // only used by alert swiss

  Area({required String areaDesc, required geoJson})
      : this.description = areaDesc,
        this.geoJson = geoJson;

  Area.withRegion({required String areaDesc, required geoJson, required region})
      : this.description = areaDesc,
        this.region = region,
        this.geoJson = geoJson;

  Area.fromJson(Map<String, dynamic> json)
      : description = json['areaDesc'],
        geoJson = json['geoJson'] ?? "",
        region = json['region'];

  Area.fromJsonWithAPIData(Map<String, dynamic> json, String geoJson)
      : description = json['areaDesc'],
        geoJson = geoJson,
        region = json['region'];

  /*
  /// store color information about the polygons of the area
  static   Map<String, dynamic> _geoJsonProperties(dynamic data) {
    return {
      'warnId': data['warnId'],
      'areaId': data['areaId'],
      'strokeColor': data['strokeColor'],
      'strokeOpacity': data['strokeOpacity'],
      'strokeWeight': data['strokeWeight'],
      'fillColor': data['fillColor'],
      'fillOpacity': data['fillOpacity'],
      'zIndex': data['zIndex'],
    };
  }
  }*/

  Map<String, dynamic> toJson() =>
      {'areaDesc': description, 'region': region, 'geoJson': geoJson};

  /// create a list with all latLon for all geoJsonFeatures
  List<LatLng> getListWithAllPolygons() {
    List<LatLng> result = [];
    GeoJsonParser geoJsonParser = GeoJsonParser();
    geoJsonParser.parseGeoJsonAsString(geoJson);
    for (Polygon i in geoJsonParser.polygons) {
      result.addAll(i.points);
    }
    return result;
  }

  /// create a list of area from the stored json data
  static List<Area> areaListFromJson(var data) {
    List<Area> _result = [];
    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        _result.add(Area.fromJson(data[i]));
      }
    }
    return _result;
  }

  /// create a list of area from the API Data
  static List<Area> areaListFromJsonWithAPIData(var data, String geoJson) {
    List<Area> _result = [];
    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        _result.add(Area.fromJsonWithAPIData(data[i], geoJson));
      }
    }
    return _result;
  }
}
