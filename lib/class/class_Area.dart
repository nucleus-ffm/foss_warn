import '../services/createAreaListFromJson.dart';
import 'class_Geocode.dart';

class Area {
  String areaDescription; // Kreisname
  List<Geocode> geocodeList; // Liste mit Ortschaften

  Area({required String areaDesc, required List<Geocode> geocodeList})
      : this.areaDescription = areaDesc,
        this.geocodeList = geocodeList;

  Area.fromJson(Map<String, dynamic> json)
      : areaDescription = json['areaDesc'],
        geocodeList = geocodeListFromJson(json['geocodeList']);

  Map<String, dynamic> toJson() => {
        'areaDesc': areaDescription,
        'geocodeList': geocodeList,
      };
}
