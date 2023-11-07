import 'dart:convert';
import 'package:foss_warn/enums/DataFetchStatus.dart';
import 'package:foss_warn/services/alertSwiss.dart';

import '../enums/Certainty.dart';
import '../enums/Severity.dart';
import '../main.dart';
import '../class/class_WarnMessage.dart';
import '../class/class_Area.dart';
import '../class/class_Geocode.dart';
import 'listHandler.dart';
import 'sendStatusNotification.dart';
import 'saveAndLoadSharedPreferences.dart';

import 'package:http/http.dart';

/// fetch data from (old) API
Future getData(bool useEtag) async {
  try {
    Response _response; //response var for get request
    var _data; //var for response data

    List<WarnMessage> _tempWarnMessageList = [];
    _tempWarnMessageList.clear();
    //print("create new Warn Message List");

    await loadSettings();
    await loadETags();

    // Get from MOWAS
    print("get from Mowas");
    var urlMowas =
        Uri.parse('https://warnung.bund.de/bbk.mowas/gefahrendurchsagen.json');

    if (useEtag) {
      _response = await get(urlMowas, headers: {'If-None-Match': appState.mowasETag}).timeout(userPreferences.networkTimeout);

    } else {
      _response = await get(urlMowas).timeout(userPreferences.networkTimeout);
    }

    //print("Response status: " + response.statusCode.toString());
    //check response code 200 -> success
    if (_response.statusCode == 200) {
      _data = jsonDecode(utf8.decode(_response.bodyBytes));
      //update status and count messages
      appState.mowasStatus = true;
      if (_response.headers["etag"] != null) {
        appState.mowasETag = (_response.headers["etag"])!;
      } else {
        print("Error with Etag: " + _response.headers.toString());
      }
      appState.mowasWarningsCount = _data.length;

      try {
        appState.mowasParseStatus = true;
        // parse Json and create WarnMessage class instances from it
        for (var i = 0; i <= _data.length - 1; i++) {
          List<Geocode> generateGeoCodeList(int i, int s) {
            List<Geocode> tempGeocodeList = [];
            for (var j = 0;
                j <= _data[i]["info"][0]["area"][s]["geocode"].length - 1;
                j++) {
              Geocode tempGeocode = Geocode(
                  geocodeName: _data[i]["info"][0]["area"][s]["geocode"][j]
                      ["valueName"],
                  geocodeNumber: _data[i]["info"][0]["area"][s]["geocode"][j]
                      ["value"],
                  latitude: "-1",
                  longitude: "-1",
                  PLZ: "-1");
              tempGeocodeList.add(tempGeocode);
            }
            return tempGeocodeList;
          }

          List<Area> generateAreaList(int i) {
            List<Area> tempAreaList = [];
            //loop through list of areas
            for (var s = 0; s <= _data[i]["info"][0]["area"].length - 1; s++) {
              Area tempArea = Area(areaDesc: "", geocodeList: []); //init clear
              tempArea.areaDescription =
                  _data[i]["info"][0]["area"][s]["areaDesc"];
              tempArea.geocodeList = generateGeoCodeList(i, s);
              tempAreaList.add(tempArea);
            }
            return tempAreaList;
          }

          WarnMessage tempWarnMessage = WarnMessage(
              source: "MOWAS",
              identifier: _data[i]["identifier"] ?? "?",
              sender: _data[i]["sender"] ?? "?",
              sent: _data[i]["sent"] ?? "?",
              status: _data[i]["status"] ?? "?",
              messageType: _data[i]["msgType"] ?? "?",
              scope: _data[i]["scope"] ?? "?",
              category: _data[i]["info"][0]["category"][0] ?? "?",
              event: _data[i]["info"][0]["event"] ?? "?",
              urgency: _data[i]["info"][0]["urgency"] ?? "?",
              severity: getSeverity(
                  _data[i]["info"][0]["severity"].toString().toLowerCase()),
              certainty: getCertainty(
                  _data[i]["info"][0]["certainty"].toString().toLowerCase()),
              effective: _data[i]["info"][0]["effective"] ?? "",
              onset: _data[i]["info"][0]["onset"] ?? "",
              expires: _data[i]["info"][0]["expires"] ?? "",
              headline: _data[i]["info"][0]["headline"] ?? "?",
              description: _data[i]["info"][0]["description"] ?? "",
              instruction: _data[i]["info"][0]["instruction"] ?? "",
              publisher: _data[i]["info"][0]["parameter"][2]["value"] ?? "?",
              contact: _data[i]["info"][0]["contact"] ?? "",
              web: _data[i]["info"][0]["web"] ?? "",
              areaList: generateAreaList(i),
              notified: false,
              read: false);
          _tempWarnMessageList.add(tempWarnMessage);
        }
      } catch (e) {
        print("Error while paring mowas data: " + e.toString());
        appState.mowasParseStatus = false;
      }
    } else if (_response.statusCode == 304) {
      // nothing changed
      print("no change for mowas");
      appState.mowasStatus = true;
      appState.mowasParseStatus = true;
    } else {
      //something went wrong
      print("can not get mowas data" + _response.statusCode.toString());
      appState.mowasStatus = false;
    }

    // GET from KATWARN
    print("get from Katwarn");
    var urlKatwarn =
        Uri.parse('https://warnung.bund.de/bbk.katwarn/warnmeldungen.json');
    if (useEtag) {
      _response = await get(urlKatwarn, headers: {'If-None-Match': appState.katwarnETag}).timeout(userPreferences.networkTimeout);

    } else {
      _response = await get(urlKatwarn).timeout(userPreferences.networkTimeout);
    }
    //print("Response status: " + response.statusCode.toString());
    if (_response.statusCode == 200) {
      _data = jsonDecode(utf8.decode(_response.bodyBytes));
      if (_response.headers["etag"] != null) {
        appState.katwarnETag = (_response.headers["etag"])!;
      } else {
        print("Error with Etag: " + _response.headers.toString());
      }

      //update status und count messages
      appState.katwarnStatus = true;
      appState.katwarnWarningsCount = _data.length;

      try {
        appState.katwarnParseStatus = true;
        // parse Json and create WarnMessage class instances from it
        for (var i = 0; i <= _data.length - 1; i++) {
          List<Geocode> generateGeoCodeList(int i, int s) {
            List<Geocode> tempGeocodeList = [];
            for (var j = 0;
                j <= _data[i]["info"][0]["area"][s]["geocode"].length - 1;
                j++) {
              Geocode tempGeocode = Geocode(
                  geocodeName: _data[i]["info"][0]["area"][s]["geocode"][j]
                      ["valueName"],
                  geocodeNumber: _data[i]["info"][0]["area"][s]["geocode"][j]
                      ["value"],
                  latitude: "-1",
                  longitude: "-1",
                  PLZ: "-1");
              tempGeocodeList.add(tempGeocode);
            }
            return tempGeocodeList;
          }

          List<Area> generateAreaList(int i) {
            List<Area> tempAreaList = [];
            //loop through list of areas
            for (var s = 0; s <= _data[i]["info"][0]["area"].length - 1; s++) {
              Area tempArea = Area(areaDesc: "", geocodeList: []); //init clear
              tempArea.areaDescription =
                  _data[i]["info"][0]["area"][s]["areaDesc"];
              tempArea.geocodeList = generateGeoCodeList(i, s);
              tempAreaList.add(tempArea);
            }
            return tempAreaList;
          }

          WarnMessage tempWarnMessage = WarnMessage(
              source: "KATWARN",
              identifier: _data[i]["identifier"] ?? "?",
              sender: _data[i]["sender"] ?? "?",
              sent: _data[i]["sent"] ?? "?",
              status: _data[i]["status"] ?? "?",
              messageType: _data[i]["msgType"] ?? "?",
              scope: _data[i]["scope"] ?? "?",
              category: _data[i]["info"][0]["category"][0] ?? "?",
              event: _data[i]["info"][0]["event"] ?? "?",
              urgency: _data[i]["info"][0]["urgency"] ?? "?",
              severity: getSeverity(
                  _data[i]["info"][0]["severity"].toString().toLowerCase()),
              certainty: getCertainty(
                  _data[i]["info"][0]["certainty"].toString().toLowerCase()),
              effective: _data[i]["info"][0]["effective"] ?? "",
              onset: _data[i]["info"][0]["onset"] ?? "",
              expires: _data[i]["info"][0]["expires"] ?? "",
              headline: _data[i]["info"][0]["headline"] ?? "?",
              description: _data[i]["info"][0]["description"] ?? "",
              instruction: _data[i]["info"][0]["instruction"] ?? "",
              publisher: _data[i]["info"][0]["parameter"][2]["value"] ?? "?",
              contact: _data[i]["info"][0]["contact"] ?? "",
              web: _data[i]["info"][0]["web"] ?? "",
              areaList: generateAreaList(i),
              notified: false,
              read: false);
          _tempWarnMessageList.add(tempWarnMessage);
        }
      } catch (e) {
        print("Errror wile parsing katwarn Data: " + e.toString());
        appState.katwarnParseStatus = false;
      }
    } else if (_response.statusCode == 304) {
      // nothing changed
      print("no change for katwarn");
      appState.katwarnStatus = true;
      appState.katwarnParseStatus = true;
    } else {
      //something went wrong
      print("can not get Katwarn data");
      appState.katwarnStatus = false;
    }

    // GET from BIWAPP
    print("get from Biwapp");
    var urlBiwapp =
        Uri.parse('https://warnung.bund.de/bbk.biwapp/warnmeldungen.json');
    if (useEtag) {
      _response = await get(urlBiwapp, headers: {'If-None-Match': appState.biwappETag}).timeout(userPreferences.networkTimeout);
    } else {
      _response = await get(urlBiwapp).timeout(userPreferences.networkTimeout);
    }
    //print("Response status: " + response.statusCode.toString());
    if (_response.statusCode == 200) {
      _data = jsonDecode(utf8.decode(_response.bodyBytes));
      // store etag
      if (_response.headers["etag"] != null) {
        appState.biwappETag = (_response.headers["etag"])!;
      } else {
        print("Error with Etag: " + _response.headers.toString());
      }
      //check status and count messages
      appState.biwappStatus = true;
      appState.biwappWarningsCount = _data.length;

      try {
        appState.biwappParseStatus = true;
        // parse Json and create WarnMessage class instances from it
        for (var i = 0; i < _data.length; i++) {
          //print("[get biwapp data] i= $i länge= ${data.length}");

          List<Geocode> generateGeoCodeList(int i, int s) {
            List<Geocode> tempGeocodeList = [];
            for (var j = 0;
                j <= _data[i]["info"][0]["area"][s]["geocode"].length - 1;
                j++) {
              Geocode tempGeocode = Geocode(
                  geocodeName: _data[i]["info"][0]["area"][s]["geocode"][j]
                      ["valueName"],
                  geocodeNumber: _data[i]["info"][0]["area"][s]["geocode"][j]
                      ["value"],
                  latitude: "-1",
                  longitude: "-1",
                  PLZ: "-1");
              tempGeocodeList.add(tempGeocode);
            }
            return tempGeocodeList;
          }

          List<Area> generateAreaList(int i) {
            List<Area> tempAreaList = [];
            //loop through list of areas
            for (var s = 0; s <= _data[i]["info"][0]["area"].length - 1; s++) {
              Area tempArea = Area(areaDesc: "", geocodeList: []); //init clear
              tempArea.areaDescription =
                  _data[i]["info"][0]["area"][s]["areaDesc"];
              tempArea.geocodeList = generateGeoCodeList(i, s);
              tempAreaList.add(tempArea);
            }
            return tempAreaList;
          }

          WarnMessage tempWarnMessage = WarnMessage(
              source: "BIWAPP",
              identifier: _data[i]["identifier"] ?? "?",
              sender: _data[i]["sender"] ?? "?",
              sent: _data[i]["sent"] ?? "?",
              status: _data[i]["status"] ?? "?",
              messageType: _data[i]["msgType"] ?? "?",
              scope: _data[i]["scope"] ?? "?",
              category: _data[i]["info"][0]["category"][0] ?? "?",
              event: _data[i]["info"][0]["event"] ?? "?",
              urgency: _data[i]["info"][0]["urgency"] ?? "?",
              severity: getSeverity(
                  _data[i]["info"][0]["severity"].toString().toLowerCase()),
              certainty: getCertainty(
                  _data[i]["info"][0]["certainty"].toString().toLowerCase()),
              effective: _data[i]["info"][0]["effective"] ?? "",
              onset: _data[i]["info"][0]["onset"] ?? "",
              expires: _data[i]["info"][0]["expires"] ?? "",
              headline: _data[i]["info"][0]["headline"] ?? "?",
              description: _data[i]["info"][0]["description"] ?? "",
              instruction: _data[i]["info"][0]["instruction"] ?? "",
              publisher: _data[i]["info"][0]["parameter"][0]["value"] ??
                  "?", // different to others ["parameter"][0]
              contact: _data[i]["info"][0]["contact"] ?? "",
              web: _data[i]["info"][0]["web"] ?? "",
              areaList: generateAreaList(i),
              notified: false,
              read: false);
          _tempWarnMessageList.add(tempWarnMessage);
        }
      } catch (e) {
        print("Error while parsing biwapp data: " + e.toString());
        appState.biwappParseStatus = false;
      }
    } else if (_response.statusCode == 304) {
      // nothing changed
      appState.biwappStatus = true;
      appState.biwappParseStatus = true;
    } else {
      //something went wrong
      print("no change for biwapp");
      print("can not get biwwapp data");
      appState.biwappStatus = false;
    }

    // GET from DWD
    print("get from DWD");
    var urlDWDwarnings = Uri.parse(
        'https://warnung.bund.de/bbk.dwd/unwetter.json'); //https://s3.eu-central-1.amazonaws.com/app-prod-static.warnwetter.de/v16/gemeinde_warnings.json

    if (useEtag) {
      _response = await get(urlDWDwarnings, headers: {'If-None-Match': appState.dwdETag}).timeout(userPreferences.networkTimeout);

    } else {
      _response = await get(urlDWDwarnings).timeout(userPreferences.networkTimeout);
    }

    //print("Response status: " + response.statusCode.toString());
    if (_response.statusCode == 200) {
      //updates status
      appState.dwdStatus = true;

      _data = jsonDecode(utf8.decode(_response.bodyBytes));
      //store etag
      if (_response.headers["etag"] != null) {
        appState.dwdETag = (_response.headers["etag"])!;
      } else {
        print("Error with Etag: " + _response.headers.toString());
      }

      appState.dwdWarningsCount = _data.length;

      try {
        appState.dwdParseStatus = true;
        for (var i = 0; i <= _data.length - 1; i++) {
          List<Geocode> generateGeoCodeList(int i, int s) {
            List<Geocode> tempGeocodeList = [];
            for (var j = 0;
                j <= _data[i]["info"][0]["area"][s]["geocode"].length - 1;
                j++) {
              Geocode tempGeocode = Geocode(
                  geocodeName: _data[i]["info"][0]["area"][s]["geocode"][j]
                      ["valueName"],
                  geocodeNumber: _data[i]["info"][0]["area"][s]["geocode"][j]
                      ["value"],
                  latitude: "-1",
                  longitude: "-1",
                  PLZ: "-1");
              tempGeocodeList.add(tempGeocode);
            }
            return tempGeocodeList;
          }

          List<Area> generateAreaList(int i) {
            List<Area> tempAreaList = [];
            //loop through list of areas
            for (var s = 0; s <= _data[i]["info"][0]["area"].length - 1; s++) {
              Area tempArea = Area(areaDesc: "", geocodeList: []); //init clear
              tempArea.areaDescription =
                  _data[i]["info"][0]["area"][s]["areaDesc"];
              tempArea.geocodeList = generateGeoCodeList(i, s);
              tempAreaList.add(tempArea);
            }
            return tempAreaList;
          }

          WarnMessage tempWarnMessage = WarnMessage(
              source: "DWD",
              identifier: _data[i]["identifier"] ?? "?",
              sender: _data[i]["sender"] ?? "?",
              sent: _data[i]["sent"] ?? "?",
              status: _data[i]["status"] ?? "?",
              messageType: _data[i]["msgType"] ?? "?",
              scope: _data[i]["scope"] ?? "",
              category: _data[i]["info"][0]["category"][0] ?? "?",
              event: _data[i]["info"][0]["event"] ?? "?",
              urgency: _data[i]["info"][0]["urgency"] ?? "?",
              severity: getSeverity(
                  _data[i]["info"][0]["severity"].toString().toLowerCase()),
              certainty: getCertainty(
                  _data[i]["info"][0]["certainty"].toString().toLowerCase()),
              onset: _data[i]["info"][0]["onset"] ?? "",
              expires: _data[i]["info"][0]["expires"] ?? "",
              headline: _data[i]["info"][0]["headline"] ?? "?",
              description: _data[i]["info"][0]["description"] ?? "",
              instruction: _data[i]["info"][0]["instruction"] ?? "",
              publisher: _data[i]["info"][0]["senderName"] ?? "?",
              contact: _data[i]["info"][0]["contact"] ?? "?",
              web: _data[i]["info"][0]["web"] ?? "?",
              areaList: generateAreaList(i),
              notified: false,
              read: false);
          _tempWarnMessageList.add(tempWarnMessage);
        }
      } catch (e) {
        print("Error while parsing DWD Data: " + e.toString());
        appState.dwdParseStatus = false;
      }
    } else if (_response.statusCode == 304) {
      // nothing changed
      print("no change for dwd");
      appState.dwdStatus = true;
      appState.dwdParseStatus = true;
    } else {
      //something went wrong
      print("can not get DWD data");
      appState.dwdStatus = false;
    }

    // GET from HWZ
    print("get from LHP");
    var urlLHPwarnings =
        Uri.parse('https://warnung.bund.de/bbk.lhp/hochwassermeldungen.json');
    if (useEtag) {
      _response = await get(urlLHPwarnings, headers: {'If-None-Match': appState.lhpETag}).timeout(userPreferences.networkTimeout);

    } else {
      _response = await get(urlLHPwarnings).timeout(userPreferences.networkTimeout);
    }
    //print("Response status: " + response.statusCode.toString());
    if (_response.statusCode == 200) {
      //updates status
      appState.lhpStatus = true;

      _data = jsonDecode(utf8.decode(_response.bodyBytes));
      if (_response.headers["etag"] != null) {
        appState.lhpETag = (_response.headers["etag"])!;
      } else {
        print("Error with Etag: " + _response.headers.toString());
      }

      //count messages
      appState.lhpWarningsCount = _data.length;

      try {
        appState.lhpParseStatus = true;
        for (var i = 0; i <= _data.length - 1; i++) {
          List<Geocode> generateGeoCodeList(int i, int s) {
            List<Geocode> tempGeocodeList = [];
            for (var j = 0;
                j <= _data[i]["info"][0]["area"][s]["geocode"].length - 1;
                j++) {
              Geocode tempGeocode = Geocode(
                  geocodeName: _data[i]["info"][0]["area"][s]["geocode"][j]
                      ["valueName"],
                  geocodeNumber: _data[i]["info"][0]["area"][s]["geocode"][j]
                      ["value"],
                  latitude: "-1",
                  longitude: "-1",
                  PLZ: "-1");
              tempGeocodeList.add(tempGeocode);
            }
            return tempGeocodeList;
          }

          List<Area> generateAreaList(int i) {
            List<Area> tempAreaList = [];
            //loop through list of areas
            for (var s = 0; s <= _data[i]["info"][0]["area"].length - 1; s++) {
              Area tempArea = Area(areaDesc: "", geocodeList: []); //init clear
              tempArea.areaDescription =
                  _data[i]["info"][0]["area"][s]["areaDesc"];
              tempArea.geocodeList = generateGeoCodeList(i, s);
              tempAreaList.add(tempArea);
            }
            return tempAreaList;
          }

          WarnMessage tempWarnMessage = WarnMessage(
              source: "LHP",
              identifier: _data[i]["identifier"] ?? "?",
              sender: _data[i]["sender"] ?? "?",
              sent: _data[i]["sent"] ?? "?",
              status: _data[i]["status"] ?? "?",
              messageType: _data[i]["msgType"] ?? "?",
              scope: _data[i]["scope"] ?? "",
              category: _data[i]["info"][0]["category"][0] ?? "?",
              event: _data[i]["info"][0]["event"] ?? "?",
              urgency: _data[i]["info"][0]["urgency"] ?? "?",
              severity: getSeverity(
                  _data[i]["info"][0]["severity"].toString().toLowerCase()),
              certainty: getCertainty(
                  _data[i]["info"][0]["certainty"].toString().toLowerCase()),
              effective: _data[i]["info"][0]["effective"] ?? "",
              onset: _data[i]["info"][0]["onset"] ?? "",
              expires: _data[i]["info"][0]["expires"] ?? "",
              headline: _data[i]["info"][0]["headline"] ?? "?",
              description: _data[i]["info"][0]["description"] ?? "",
              instruction: _data[i]["info"][0]["instruction"] ?? "",
              publisher: _data[i]["info"][0]["senderName"] ?? "?",
              contact: _data[i]["info"][0]["contact"] ?? "?",
              web: _data[i]["info"][0]["web"] ?? "?",
              areaList: generateAreaList(i),
              notified: false,
              read: false);
          _tempWarnMessageList.add(tempWarnMessage);
        }
      } catch (e) {
        print("Error while parsing LHP Data: " + e.toString());
        appState.lhpParseStatus = false;
      }
    } else if (_response.statusCode == 304) {
      // nothing changed
      print("no change for lhp");
      appState.lhpStatus = true;
      appState.lhpParseStatus = true;
    } else {
      //something went wrong
      print("can not get LHP data");
      appState.lhpStatus = false;
    }

    allWarnMessageList.clear(); //clear List
    allWarnMessageList =
        _tempWarnMessageList; // transfer temp List in real list
    appState.dataFetchStatusOldAPI = DataFetchStatus.success;

    if (userPreferences.activateAlertSwiss) {
      await callAlertSwissAPI();
    }

    // cacheWarnings for offline use not ready yet
    // cacheWarnings();

    //print("New WarnList ist here");
    if (userPreferences.showStatusNotification) {
      sendStatusUpdateNotification(true);
    }
  } catch (e) {
    print("Error while trying to fetch data: " + e.toString());
    // print("load cache");
    // loadCachedWarnings();
    appState.dwdStatus = false;
    appState.mowasStatus = false;
    appState.biwappStatus = false;
    appState.katwarnStatus = false;
    appState.dataFetchStatusOldAPI = DataFetchStatus.error;
    appState.lhpStatus = false;
    if (userPreferences.showStatusNotification) {
      sendStatusUpdateNotification(false);
    }
  }
  saveETags();
  return "";
}
