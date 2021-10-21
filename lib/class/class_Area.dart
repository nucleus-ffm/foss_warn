import 'class_Geocode.dart';

class Area {
  String areaDesc; //Kreisname
  List<Geocode> geocodeList; //Liste mit Ortschaften
  Area({required this.areaDesc, required this.geocodeList});
}