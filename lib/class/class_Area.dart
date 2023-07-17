import '../services/createAreaListFromJson.dart';
import 'class_Geocode.dart';

class Area {
  String _areaDesc; // Kreisname
  List<Geocode> _geocodeList; // Liste mit Ortschaften
  Area({required String areaDesc, required List<Geocode> geocodeList})
      : _geocodeList = geocodeList,
        _areaDesc = areaDesc;

  String getAreaDescription() => _areaDesc;
  void setAreaDescription(String desc) => _areaDesc = desc;
  List<Geocode> getGeocodeList() => _geocodeList;
  void setGeocodeList(List<Geocode> list) => _geocodeList = list;

  Area.fromJson(Map<String, dynamic> json)
      : _areaDesc = json['areaDesc'],
        _geocodeList = geocodeListFromJson(json['geocodeList']);

  Map<String, dynamic> toJson() => {
        'areaDesc': _areaDesc,
        'geocodeList': _geocodeList,
      };
}
