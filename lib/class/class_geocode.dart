import 'package:latlong2/latlong.dart';

class Geocode {
  final String _geocodeName;
  final String _geocodeNumber;
  String _stateName = "";
  final LatLng _latLng;
  final String _plz;

  Geocode({
    required String geocodeName,
    required String geocodeNumber,
    required latLng,
    required plz,
  })  : _geocodeNumber = geocodeNumber,
        _geocodeName = geocodeName,
        _latLng = latLng,
        _plz = plz {
    _stateName = _extractStateNameFromGeocode();
  }

  String get geocodeNumber => _geocodeNumber;
  String get stateName => _stateName;
  String get geocodeName => _geocodeName;
  LatLng get latLng => _latLng;
  String get plz => _plz;

  Geocode.fromJson(Map<String, dynamic> json)
      : _geocodeName = json['geocodeName'],
        _geocodeNumber = json['geocodeNumber'],
        _stateName = json['stateName'] ?? "-1",
        _latLng = json['latLng'] != null
            ? LatLng.fromJson(json['latLng'])
            : LatLng(0.0, 0.0),
        _plz = json['PLZ'] ?? "-1";

  Map<String, dynamic> toJson() => {
        'geocodeName': _geocodeName,
        'geocodeNumber': _geocodeNumber,
        'stateName': _stateName,
        'latLng': _latLng,
        'PLZ': _plz
      };

  String _extractStateNameFromGeocode() {
    if (_geocodeNumber.length < 2) return "error";

    String stateCode = _geocodeNumber.substring(0, 2);

    switch (stateCode) {
      case "01":
        return "SH"; // Schleswig-Holstein
      case "02":
        return "HH"; // Freie und Hansestadt Hamburg
      case "03":
        return "NI"; // Niedersachsen
      case "04":
        return "HB"; // Freie Hansestadt Bremen
      case "05":
        return "NW"; // Nordrhein-Westfalen
      case "06":
        return "HE"; // Hessen
      case "07":
        return "RP"; // Rheinland-Pfalz
      case "08":
        return "BW"; // Baden-Württemberg
      case "09":
        return "BY"; // Bayern
      case "10":
        return "SL"; // Saarland
      case "11":
        return "B"; // Berlin
      case "12":
        return "BB"; // Brandenburg
      case "13":
        return "MV"; // Mecklenburg-Vorpommern
      case "14":
        return "SN"; // Sachsen
      case "15":
        return "LSA"; // Sachsen-Anhalt
      case "16":
        return "TH"; // Thüringen
      default:
        return "error";
    }
  }
}
