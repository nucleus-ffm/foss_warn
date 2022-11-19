/// extracts the first two letters from the gecode
/// and returns the corresponding state
String extractStateNameFromGeocode(String geocode) {
  if(geocode.length < 2)
    return "error";
  String stateCode = geocode.substring(0, 2);

  switch (stateCode) {
    case "01":
      return "(SH)"; //Schleswig-Holstein
    case "02":
      return "(HH)";  // Freie und Hansestadt Hamburg
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
      return "(B)";  //Berlin
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