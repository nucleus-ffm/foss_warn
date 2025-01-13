import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../class/abstract_place.dart';
import '../class/class_alert_swiss_place.dart';
import '../class/class_error_logger.dart';
import '../class/class_geocode.dart';
import '../class/class_nina_place.dart';
import '../main.dart';
import 'list_handler.dart';
import 'save_and_load_shared_preferences.dart';

import 'package:http/http.dart';

//  @todo: move to geocode class?
Future<void> geocodeHandler() async {
  try {
    final data = await getPlaces();

    if (data == null) {
      debugPrint("could not reach geocode source");
      return;
    }

    allAvailablePlacesNames.clear();

    for (int i = 0; i < data["Daten"].length; i++) {
      Place place = NinaPlace(
          name: data["Daten"][i][0],
          geocode: Geocode(
              geocodeNumber: data["Daten"][i][4].toString(),
              geocodeName: data["Daten"][i][0].toString(),
              latLng: LatLng(data["Daten"][i][3], data["Daten"][i][2]),
              plz: data["Daten"][i][1].toString()));

      // we can not receive any warning for OT (Ortsteile)
      if (place.name.contains("OT")) continue;

      // add to list, used to display the Places List
      allAvailablePlacesNames.add(place);
    }

    // add alert swiss places to list
    createAlertSwissPlacesMap();

    debugPrint("[geocodehandler] finish");
  } catch (e) {
    debugPrint("[geocodehandler] something went wrong: $e");
    ErrorLogger.writeErrorLog("geocodeHandler.dart",
        "Error while getting geocode data", e.toString());
    appState.error = true;
  }
}

/// Fetch places from sharedPrefs (cache) or server.
/// Returns a JSON with an unparsed (!) list of Place(s) in field "daten".
/// throws Exception if the resource could not reached
Future<dynamic> getPlaces() async {
  const String url =
      "https://raw.githubusercontent.com/nucleus-ffm/ARSForNina/main/ARSNinaMini.json";

  dynamic savedData = await loadGeocode();

  // check if data is stored and the data contains a PLZ (new dataset)
  if (savedData != null && savedData["Daten"][0][1] != null) {
    debugPrint("[geocodeHandler] data already stored");
    return savedData;
  } else {
    final Response response =
        await get(Uri.parse(url)).timeout(userPreferences.networkTimeout);

    if (response.statusCode != 200) {
      throw Exception("Resource did not return a 200 HTTP status code");
    }
    debugPrint("[geocodehandler] got data");

    final data = utf8.decode(response.bodyBytes);
    saveGeocodes(data);
    return jsonDecode(data);
  }
}

/// create map with short name and full name and create List with full name
void createAlertSwissPlacesMap() {
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Zürich", shortName: "ZH"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Bern", shortName: "BE"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Luzern", shortName: "LU"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Uri", shortName: "UR"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Schwyz", shortName: "SZ"));
  allAvailablePlacesNames
      .add(AlertSwissPlace(name: "Obwalden", shortName: "OW"));
  allAvailablePlacesNames
      .add(AlertSwissPlace(name: "Nidwalden", shortName: "NW"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Glarus", shortName: "GL"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Zug", shortName: "ZG"));
  allAvailablePlacesNames
      .add(AlertSwissPlace(name: "Freiburg", shortName: "FR"));
  allAvailablePlacesNames
      .add(AlertSwissPlace(name: "Solothurn", shortName: "SO"));
  allAvailablePlacesNames
      .add(AlertSwissPlace(name: "Basel-Stadt", shortName: "BS"));
  allAvailablePlacesNames
      .add(AlertSwissPlace(name: "Basel-Landschaft", shortName: "BL"));
  allAvailablePlacesNames
      .add(AlertSwissPlace(name: "Schaffhausen", shortName: "SH"));
  allAvailablePlacesNames
      .add(AlertSwissPlace(name: "Appenzell Ausserrhoden", shortName: "AR"));
  allAvailablePlacesNames
      .add(AlertSwissPlace(name: "Appenzell Innerrhoden", shortName: "AI"));
  allAvailablePlacesNames
      .add(AlertSwissPlace(name: "St. Gallen", shortName: "SG"));
  allAvailablePlacesNames
      .add(AlertSwissPlace(name: "Graubünden", shortName: "GR"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Aargau", shortName: "AG"));
  allAvailablePlacesNames
      .add(AlertSwissPlace(name: "Thurgau", shortName: "TG"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Ticino", shortName: "TI"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Vaud", shortName: "VD"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Valais", shortName: "VS"));
  allAvailablePlacesNames
      .add(AlertSwissPlace(name: "Neuchâtel", shortName: "NE"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Genève", shortName: "GE"));
  allAvailablePlacesNames.add(AlertSwissPlace(name: "Jura", shortName: "JU"));
}
