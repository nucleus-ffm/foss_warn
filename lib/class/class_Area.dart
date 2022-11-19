import '../services/createAreaListFromjson.dart';
import 'class_Geocode.dart';

class Area {
  String areaDesc; // Kreisname
  List<Geocode> geocodeList; // Liste mit Ortschaften
  Area({required this.areaDesc, required this.geocodeList});

  Area.fromJson(Map<String, dynamic> json)
      : areaDesc = json['areaDesc'],
        geocodeList = geocodeListFromJson(json['geocodeList']);

  Map<String, dynamic> toJson() => {
    'areaDesc': areaDesc,
    'geocodeList': geocodeList,
  };
}