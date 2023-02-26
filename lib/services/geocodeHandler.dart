import 'dart:convert';
import 'package:foss_warn/class/class_AlertSwissPlace.dart';
import 'package:foss_warn/class/class_Geocode.dart';
import 'package:foss_warn/class/class_NinaPlace.dart';
import 'package:foss_warn/services/listHandler.dart';
import 'package:foss_warn/services/saveAndLoadSharedPreferences.dart';
import 'package:http/http.dart';

import '../class/abstract_Place.dart';
import 'allPlacesList.dart';


const String url =
    "https://www.xrepository.de/api/xrepository/urn:de:bund:destatis"
    ":bevoelkerungsstatistik:schluessel:rs_2021-07-31/download/"
    "Regionalschl_ssel_2021-07-31.json";


//  @todo: move to geocode class?
Future<void> geocodeHandler() async {
  print("[geocodehandler]");

  try {
    final data = await getPlaces();

    if (data == null) {
      print("could not reach geocode source");
      return;
    }

    allAvailablePlacesNames.clear();

    for (int i = 0; i < data["daten"].length; i++) {
      // print( "name:" +  data["daten"][i][1] + "geocodeNumber:" +  data["daten"][i][0]);
      Place place =
          NinaPlace(name: data["daten"][i][1], geocode: Geocode(geocodeNumber: data["daten"][i][0], geocodeName: ""));

      // we can not receive any warning for OT (Ortsteile)
      if (place.name.contains("OT")) continue;

      /* final placeNameWithState =
          "${place.name} ${place.geocode.stateName}"; */

      // add to map only used in background
      // geocodeMap.putIfAbsent(placeNameWithState, () => place.geocode.geocodeName);
      // add to list, used to display the Places List
      allAvailablePlacesNames.add(place);
    }

    // add alert swiss places to list
    createAlertSwissPlacesMap();

    print("[geocodehandler] finish");
  } catch (e) {
    print("[geocodehandler] something went wrong: " + e.toString());
  }
}

/// Fetch places from sharedPrefs (cache) or server.
/// Returns a JSON with an unparsed (!) list of Place(s) in field "daten".
Future<dynamic> getPlaces() async {
  dynamic savedData = await loadGeocode();

  if (savedData != null) {
    print("[geocodeHandler] data already stored");
    return savedData;
  } else {
    final Response response = await get(Uri.parse(url));
    if (response.statusCode != 200) return;

    print("[geocodehandler] got data ");
    final data = utf8.decode(response.bodyBytes);
    saveGeocodes(data);
    return jsonDecode(data);
  }
}

/// create map with short name and full name and create List with full name
void createAlertSwissPlacesMap() {

  alertSwissPlacesList.clear();

  allAvailablePlacesNames.add(AlertSwissPlace(name: "Zürich", shortName: "ZH"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Bern", shortName: "BE"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Luzern", shortName: "LU"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Uri", shortName: "UR"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Schwyz", shortName: "SZ"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Obwalden", shortName: "OW"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Nidwalden", shortName: "NW"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Glarus", shortName: "GL"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Zug", shortName: "ZG"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Freiburg", shortName: "FR"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Solothurn", shortName: "SO"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Basel-Stadt", shortName: "BS"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Basel-Landschaft", shortName: "BL"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Schaffhausen", shortName: "SH"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Appenzell Ausserrhoden", shortName: "AR"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Appenzell Innerrhoden", shortName: "AI"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "St. Gallen", shortName: "SG"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Graubünden", shortName: "GR"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Aargau", shortName: "AG"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Thurgau", shortName: "TG"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Ticino", shortName: "TI"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Vaud", shortName: "VD"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Valais", shortName: "VS"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Neuchâtel", shortName: "NE"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Genève", shortName: "GE"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Jura", shortName: "JU"));
}
