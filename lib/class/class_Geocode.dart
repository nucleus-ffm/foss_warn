class Geocode {
  String geocodeName;
  String geocodeNumber;
  String stateName = "";

  Geocode({required this.geocodeName, required this.geocodeNumber}) {
    stateName = _extractStateNameFromGeocode();
  }

  Geocode.fromJson(Map<String, dynamic> json)
      : geocodeName = json['geocodeName'],
        geocodeNumber = json['geocodeNumber'],
        stateName = json['stateName'];

  Map<String, dynamic> toJson() => {
        'geocodeName': geocodeName,
        'geocodeNumber': geocodeNumber,
        'stateName': stateName
      };

  String _extractStateNameFromGeocode() {
    if (geocodeNumber.length < 2) return "error";

    String stateCode = geocodeNumber.substring(0, 2);

    switch (stateCode) {
      case "01":
        return "(SH)"; //Schleswig-Holstein
      case "02":
        return "(HH)"; // Freie und Hansestadt Hamburg
      case "03":
        return "(NI)"; // Niedersachsen
      case "04":
        return "(HB)"; // Freie Hansestadt Bremen
      case "05":
        return "(NW)"; // Nordrhein-Westfalen
      case "06":
        return "(HE)"; //Hessen
      case "07":
        return "(RP)"; //Rheinland-Pfalz
      case "08":
        return "(BW)"; //Baden-Württemberg
      case "09":
        return "(BY)"; //Bayern
      case "10":
        return "(SL)"; //Saarland
      case "11":
        return "(B)"; //Berlin
      case "12":
        return "(BB)"; //Brandenburg
      case "13":
        return "(MV)"; //Mecklenburg-Vorpommern
      case "14":
        return "(SN)"; //Sachsen
      case "15":
        return "(LSA)"; //Sachsen-Anhalt
      case "16":
        return "(TH)"; //Thüringen
      default:
        return "error";
    }
  }
}
