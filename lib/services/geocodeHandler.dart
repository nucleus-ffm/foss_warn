import 'dart:convert';
import 'package:foss_warn/class/class_Place.dart';
import 'package:foss_warn/services/listHandler.dart';
import 'package:foss_warn/services/saveAndLoadSharedPreferences.dart';
import 'package:http/http.dart';

import 'allPlacesList.dart';
import 'extractStateNameFromGeocode.dart';

const String url =
    "https://www.xrepository.de/api/xrepository/urn:de:bund:destatis"
    ":bevoelkerungsstatistik:schluessel:rs_2021-07-31/download/"
    "Regionalschl_ssel_2021-07-31.json";

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
      final place =
          Place(name: data["daten"][i][1], geocode: data["daten"][i][0]);

      // we can not receive any warning for OT (Ortsteile)
      if (place.name.contains("OT")) continue;

      final placeNameWithState =
          "${place.name} ${extractStateNameFromGeocode(place.geocode)}";

      // add to map only used in background
      geocodeMap.putIfAbsent(placeNameWithState, () => place.geocode);
      // add to list, used to display the Places List
      allAvailablePlacesNames.add(placeNameWithState);
    }

    // add alert swiss places to list
    createAlertSwissPlacesMap();

    print("[geocodehandler] finish");
  } catch (e) {
    print("[geocodehandler] something went wrong: " + e.toString());
  }
}

/// Fetch places from sharedPrefs (cache) or server.
/// Returns a JSON with a list of Place(s) in field "daten".
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
  alertSwissPlacesMap.putIfAbsent("Zürich", () => "ZH");
  alertSwissPlacesMap.putIfAbsent("Bern", () => "BE");
  alertSwissPlacesMap.putIfAbsent("Luzern", () => "LU");
  alertSwissPlacesMap.putIfAbsent("Uri", () => "UR");
  alertSwissPlacesMap.putIfAbsent("Schwyz", () => "SZ");
  alertSwissPlacesMap.putIfAbsent("Obwalden", () => "OW");
  alertSwissPlacesMap.putIfAbsent("Nidwalden", () => "NW");
  alertSwissPlacesMap.putIfAbsent("Glarus", () => "GL");
  alertSwissPlacesMap.putIfAbsent("Zug", () => "ZG");
  alertSwissPlacesMap.putIfAbsent("Freiburg", () => "FR");
  alertSwissPlacesMap.putIfAbsent("Solothurn", () => "SO");
  alertSwissPlacesMap.putIfAbsent("Basel-Stadt", () => "BS");
  alertSwissPlacesMap.putIfAbsent("Basel-Landschaft", () => "BL");
  alertSwissPlacesMap.putIfAbsent("Schaffhausen", () => "SH");
  alertSwissPlacesMap.putIfAbsent("Appenzell Ausserrhoden", () => "AR");
  alertSwissPlacesMap.putIfAbsent("Appenzell Innerrhoden", () => "AI");
  alertSwissPlacesMap.putIfAbsent("St. Gallen", () => "SG");
  alertSwissPlacesMap.putIfAbsent("Graubünden", () => "GR");
  alertSwissPlacesMap.putIfAbsent("Aargau", () => "AG");
  alertSwissPlacesMap.putIfAbsent("Thurgau", () => "TG");
  alertSwissPlacesMap.putIfAbsent("Ticino", () => "TI");
  alertSwissPlacesMap.putIfAbsent("Vaud", () => "VD");
  alertSwissPlacesMap.putIfAbsent("Valais", () => "VS");
  alertSwissPlacesMap.putIfAbsent("Neuchâtel", () => "NE");
  alertSwissPlacesMap.putIfAbsent("Genève", () => "GE");
  alertSwissPlacesMap.putIfAbsent("Jura", () => "JU");

  alertSwissPlacesList.clear();
  alertSwissPlacesList.addAll([
    "Zürich",
    "Bern",
    "Luzern",
    "Uri",
    "Schwyz",
    "Obwalden",
    "Nidwalden",
    "Glarus",
    "Zug",
    "Freiburg",
    "Solothurn",
    "Basel-Stadt",
    "Basel-Landschaft",
    "Schaffhausen",
    "Appenzell Ausserrhoden",
    "Appenzell Innerrhoden",
    "St. Gallen",
    "Graubünden",
    "Aargau",
    "Thurgau",
    "Ticino",
    "Vaud",
    "Valais",
    "Neuchâtel",
    "Genève",
    "Jura"
  ]);
  allAvailablePlacesNames.addAll(alertSwissPlacesList);
}
