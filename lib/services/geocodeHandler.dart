import 'dart:convert';
import 'package:foss_warn/services/listHandler.dart';
import 'package:foss_warn/services/saveAndLoadSharedPreferences.dart';
import 'package:http/http.dart';

import 'allPlacesList.dart';
import 'extractStateNameFromGeocode.dart';

Future<void> geocodeHandler() async {
  print("[geocodehandler]");
  var url = "https://www.xrepository.de/api/xrepository/urn:de:bund:destatis"
      ":bevoelkerungsstatistik:schluessel:rs_2021-07-31/download/"
      "Regionalschl_ssel_2021-07-31.json";
  Response response; //response var for get request
  var data; //var for response data
  try {
    dynamic? savedData = await loadGeocode();
    if (savedData != null) {
      // we don't need to laod the data from web
      print("[geocodeHandler] data already stored");
      data = savedData;
    } else {
      response = await get(Uri.parse(url));
      if (response.statusCode == 200) {
        print("[geocodehanlder] got data ");
        data = jsonDecode(utf8.decode(response.bodyBytes));
        saveGeocodes(utf8.decode(response.bodyBytes));
      }
    }
    if (data != null) {
      allAvailablePlacesNames.clear();

      for (int j = 0; j < data["daten"].length; j++) {
        // we can not receive any warning for OT => Ortsteile
        if (!data["daten"][j][1].toString().contains("OT")) {
          // add to map only used in background
          geocodeMap.putIfAbsent(
              // [1] is the name [0] is the ARS
              addStateToName(data["daten"][j][1], data["daten"][j][0]),
              () => data["daten"][j][0]);
          // add to list, used to display the Places List
          allAvailablePlacesNames.add(
              addStateToName(data["daten"][j][1], data["daten"][j][0])
          );
        }
      }

      // add alert swiss places to list
      createAlertSwissPlacesMap();

      print("[geocodehanlder] finish");
    } else {
      print("could not reach geocode source");
    }
  } catch (e) {
    print("[geocodehandler] something went wrong: " + e.toString());
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

// add the state from the geocode in "(xy)" to the given name
String addStateToName(String name, String geocode) {
  return name += " " + extractStateNameFromGeocode(geocode);
}
