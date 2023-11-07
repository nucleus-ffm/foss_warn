import 'dart:convert';
import 'package:foss_warn/class/class_Geocode.dart';
import 'package:foss_warn/class/abstract_Place.dart';
import 'package:http/http.dart';

import '../main.dart';
import '../services/apiHandler.dart';
import '../services/saveAndLoadSharedPreferences.dart';
import 'class_Area.dart';
import 'class_WarnMessage.dart';

class NinaPlace extends Place {
  final Geocode _geocode;

  NinaPlace({
    required Geocode geocode,
    required String name,
    String eTag = "",
  })  : _geocode = geocode,
        super(name: name, warnings: [], eTag: eTag);

  /// returns the name of the place with the state
  @override
  String get name => "${super.name} (${_geocode.stateName})";

  String get nameWithoutState => super.name;

  Geocode get geocode => _geocode;

  NinaPlace.withWarnings(
      {required Geocode geocode,
      required String name,
      required List<WarnMessage> warnings,
      required String eTag})
      : _geocode = geocode,
        super(name: name, warnings: warnings, eTag: eTag);

  factory NinaPlace.fromJson(Map<String, dynamic> json) {
    /// create new warnMessage objects from saved data
    List<WarnMessage> createWarningList(String data) {
      List<dynamic> _jsonData = jsonDecode(data);
      List<WarnMessage> result = [];
      for (int i = 0; i < _jsonData.length; i++) {
        result.add(WarnMessage.fromJson(_jsonData[i]));
      }
      return result;
    }

    return NinaPlace.withWarnings(
      name: json['name'] as String,
      geocode: Geocode.fromJson(json['geocode']),
      warnings: createWarningList(json['warnings']),
      eTag: (json['eTag'] ?? "") as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    try {
      return {
        'name': nameWithoutState,
        'geocode': geocode,
        'warnings': jsonEncode(warnings),
        'eTag': eTag
      };
    } catch (e) {
      print("Error nina place to json: " + e.toString());
      return {};
    }
  }

  @override

  /// calls the NINA API and store the current warnings in `warnings`
  Future<(String, bool)> callAPIAndGetWarnings() async {
    bool _successfullyFetched = true;
    String _error = "";
    List<WarnMessage> _tempWarnMessageList = [];
    _tempWarnMessageList.clear();
    String _baseUrl = "https://warnung.bund.de/api31";
    dynamic _data; //var for response _data
    // String geocode = "071110000000"; // just for testing

    try {
      Response _response;
      _response = await _getDashboard(_baseUrl);

      // 304 = with etag no change since last request
      if (_response.statusCode == 304) {
        print("Nothing change for: " + this.name);
      }
      // 200 = check if request was successfully
      else if (_response.statusCode == 200) {
        // decode the _data
        _data = jsonDecode(utf8.decode(_response.bodyBytes));
        _tempWarnMessageList.clear();
        // parse the _data into List of Warnings
        _tempWarnMessageList = await _parseNinaJsonData(_data, _baseUrl, this);
        // remove old warning
        removeOldWarningFromList(this, _tempWarnMessageList);
        userPreferences.areWarningsFromCache = false;
        print("Saving myPlacesList with new warnings");
        // store warning
        saveMyPlacesList();
      }
      // connection error
      else {
        print("could not reach: ");
        _successfullyFetched = false;
        _error += "Failed to get warnings for:  ${this.name}"
            " (Statuscode:  ${_response.statusCode} ) \n";
      }
    } catch (e) {
      print("Something went wrong while trying to call the NINA API:  $e");
      _successfullyFetched = false;
      // set areWarningFrom cache to true to display information
      userPreferences.areWarningsFromCache = true;
      _error += e.toString() + " \n";
    }
    return (_error, _successfullyFetched);
  }

  /// call the dashboard for the given place and return the response
  /// uses etag to only fetch the site if there are changes
  Future<Response> _getDashboard(String baseUrl) async {
    Response _response; //response var for get request

    // the warnings are only on kreisebene wo we only care about the first 5
    // letters from the code and fill the rest with 0s
    print(this.geocode.geocodeNumber);
    String geocode = this.geocode.geocodeNumber.substring(0, 5) + "0000000";
    Uri _urlDashboard = Uri.parse(baseUrl + "/dashboard/" + geocode + ".json");

    print("call: " + baseUrl + "/dashboard/" + geocode + ".json");
    // get overview if warnings exits for myplaces
    print("Etag for: ${this.name} is ${this.eTag}");

    _response = await get(_urlDashboard, headers: {'If-None-Match': this.eTag});

    this.eTag = _response.headers["etag"]!;
    print("new etag for: ${this.name} is:  ${_response.headers["etag"]}");
    return _response;
  }

  /// crate from the given data a new List<WarnMessage and return the list
  Future<List<WarnMessage>> _parseNinaJsonData(
      dynamic data, String baseUrl, NinaPlace place) async {
    List<WarnMessage> _tempWarnMessageList = [];
    for (int i = 0; i < data.length; i++) {
      String id = data[i]["payload"]["id"];
      String provider = data[i]["payload"]["data"]["provider"];
      print("provider: " + provider);
      Response responseDetails =
          await get(Uri.parse(baseUrl + "/warnings/" + id + ".json"));
      // check if request was successfully
      if (responseDetails.statusCode == 200) {
        var warningDetails = jsonDecode(utf8.decode(responseDetails.bodyBytes));
        WarnMessage? temp =
            _createWarning(warningDetails, provider, place.name, place.geocode);
        if (temp != null) {
          _tempWarnMessageList.add(temp);
          if (!place.warnings
              .any((element) => element.identifier == temp.identifier)) {
            print("add warning to p: " +
                temp.headline +
                " " +
                temp.notified.toString());
            place.addWarningToList(temp);
            place.incrementNumberOfWarnings();
          }

          // }  //@todo: fix displaying warnings twice
        }
      } else {
        print("[callAPI] Error: tried calling: " +
            baseUrl +
            "/warnings/" +
            id +
            ".json");
      }
    }
    return _tempWarnMessageList;
  }

  /// generate WarnMessage object
  WarnMessage? _createWarning(
      dynamic data, String provider, String placeName, Geocode geocode) {
    /// generate empty list as placeholder
    /// @todo fill with real data
    List<Area> generateAreaList(int i) {
      List<Area> tempAreaList = [];
      tempAreaList.add(
        Area(areaDesc: placeName, geocodeList: [
          geocode,
        ]),
      );
      return tempAreaList;
    }

    String findPublisher(var parameter) {
      for (int i = 0; i < parameter.length; i++) {
        if (parameter[i]["valueName"] == "sender_langname") {
          return parameter[i]["value"];
        }
      }
      return "Deutscher Wetterdienst";
    }

    try {
      return WarnMessage.fromJsonTemp(data, provider,
          findPublisher(data["info"][0]["parameter"]), generateAreaList(1));
    } catch (e) {
      print("Error parsing warning: ${data["identifier"]} -> ${e.toString()}");
    }
    return null;
  }
}
