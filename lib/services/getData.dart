import 'dart:convert';
import '../main.dart';
import '../class/class_WarnMessage.dart';
import '../class/class_Area.dart';
import '../class/class_Geocode.dart';
import 'listHandler.dart';
//import 'markWarningsAsRead.dart';
import '../views/SettingsView.dart';
import 'sendStatusNotification.dart';
import 'saveAndLoadSharedPreferences.dart';

import 'package:http/http.dart';

Future getData() async {
  try {
    Response response; //response var for get request
    var data; //var for response data

    List<WarnMessage> tempWarnMessageList = [];
    tempWarnMessageList.clear();
    //print("create new Warn Message List");

    await loadSettings(); //load setting for status notification

    // Get from MOWAS
    print("get from Mowas");
    var urlMowas =
        Uri.parse('https://warnung.bund.de/bbk.mowas/gefahrendurchsagen.json');
    response = await get(urlMowas);
    //print("Response status: " + response.statusCode.toString());
    //check response code 200 -> success
    if (response.statusCode == 200) {
      data = jsonDecode(utf8.decode(response.bodyBytes));
      //update status and count messages
      mowasStatus = true;
      mowasMessages = data.length;

      try {
        mowasParseStatus = true;
        // parse Json and create WarnMessage class instances from it
        for (var i = 0; i <= data.length - 1; i++) {
          List<Geocode> generateGeoCodeList(int i, int s) {
            List<Geocode> tempGeocodeList = [];
            for (var j = 0;
                j <= data[i]["info"][0]["area"][s]["geocode"].length - 1;
                j++) {
              Geocode tempGeocode =
                  Geocode(geocodeName: "", geocodeNumber: ""); //init
              tempGeocode.geocodeName =
                  data[i]["info"][0]["area"][s]["geocode"][j]["valueName"];
              tempGeocode.geocodeNumber =
                  data[i]["info"][0]["area"][s]["geocode"][j]["value"];
              tempGeocodeList.add(tempGeocode);
            }
            return tempGeocodeList;
          }

          List<Area> generateAreaList(int i) {
            List<Area> tempAreaList = [];
            //loop through list of areas
            for (var s = 0; s <= data[i]["info"][0]["area"].length - 1; s++) {
              Area tempArea = Area(areaDesc: "", geocodeList: []); //init clear
              tempArea.areaDesc = data[i]["info"][0]["area"][s]["areaDesc"];
              tempArea.geocodeList = generateGeoCodeList(i, s);
              tempAreaList.add(tempArea);
            }
            return tempAreaList;
          }

          WarnMessage tempWarnMessage = WarnMessage(
            source: "MOWAS",
            identifier: data[i]["identifier"] ?? "?",
            sender: data[i]["sender"] ?? "?",
            sent: data[i]["sent"] ?? "?",
            status: data[i]["status"] ?? "?",
            messageTyp: data[i]["msgType"] ?? "?",
            scope: data[i]["scope"] ?? "?",
            category: data[i]["info"][0]["category"][0] ?? "?",
            event: data[i]["info"][0]["event"] ?? "?",
            urgency: data[i]["info"][0]["urgency"] ?? "?",
            severity: data[i]["info"][0]["severity"] ?? "?",
            certainty: data[i]["info"][0]["certainty"] ?? "?",
            headline: data[i]["info"][0]["headline"] ?? "?",
            description: data[i]["info"][0]["description"] ?? "",
            instruction: data[i]["info"][0]["instruction"] ?? "",
            publisher: data[i]["info"][0]["parameter"][2]["value"] ?? "?",
            contact: data[i]["info"][0]["contact"] ?? "",
            web: data[i]["info"][0]["web"] ?? "",
            areaList: generateAreaList(i),
            //area: data[i]["info"][0]["area"][0]["areaDesc"],
            //geocodeName: generateGeoCodeNameList(i),
            //geocodeNumber: data[i]["info"][0]["area"][0]["geocode"][0]["value"],
          );
          tempWarnMessageList.add(tempWarnMessage);
        }
      } catch (e) {
        print("Error while paring mowas data: " + e.toString());
        mowasParseStatus = false;
      }
    } else {
      //something went wrong
      print("can not get mowas data");
      mowasStatus = false;
    }

    // GET from KATWARN
    print("get from Katwarn");
    var urlKatwarn =
        Uri.parse('https://warnung.bund.de/bbk.katwarn/warnmeldungen.json');
    response = await get(urlKatwarn);
    //print("Response status: " + response.statusCode.toString());
    if (response.statusCode == 200) {
      data = jsonDecode(utf8.decode(response.bodyBytes));
      //update status und count messages
      katwarnStatus = true;
      katwarnMessages = data.length;

      try {
        katwarnParseStatus = true;
        // parse Json and create WarnMessage class instances from it
        for (var i = 0; i <= data.length - 1; i++) {
          List<Geocode> generateGeoCodeList(int i, int s) {
            List<Geocode> tempGeocodeList = [];
            for (var j = 0;
                j <= data[i]["info"][0]["area"][s]["geocode"].length - 1;
                j++) {
              Geocode tempGeocode =
                  Geocode(geocodeName: "", geocodeNumber: ""); //init
              tempGeocode.geocodeName =
                  data[i]["info"][0]["area"][s]["geocode"][j]["valueName"];
              tempGeocode.geocodeNumber =
                  data[i]["info"][0]["area"][s]["geocode"][j]["value"];
              tempGeocodeList.add(tempGeocode);
            }
            return tempGeocodeList;
          }

          List<Area> generateAreaList(int i) {
            List<Area> tempAreaList = [];
            //loop through list of areas
            for (var s = 0; s <= data[i]["info"][0]["area"].length - 1; s++) {
              Area tempArea = Area(areaDesc: "", geocodeList: []); //init clear
              tempArea.areaDesc = data[i]["info"][0]["area"][s]["areaDesc"];
              tempArea.geocodeList = generateGeoCodeList(i, s);
              tempAreaList.add(tempArea);
            }
            return tempAreaList;
          }

          WarnMessage tempWarnMessage = WarnMessage(
            source: "KATWARN",
            identifier: data[i]["identifier"] ?? "?",
            sender: data[i]["sender"] ?? "?",
            sent: data[i]["sent"] ?? "?",
            status: data[i]["status"] ?? "?",
            messageTyp: data[i]["msgType"] ?? "?",
            scope: data[i]["scope"] ?? "?",
            category: data[i]["info"][0]["category"][0] ?? "?",
            event: data[i]["info"][0]["event"] ?? "?",
            urgency: data[i]["info"][0]["urgency"] ?? "?",
            severity: data[i]["info"][0]["severity"] ?? "?",
            certainty: data[i]["info"][0]["certainty"] ?? "?",
            headline: data[i]["info"][0]["headline"] ?? "?",
            description: data[i]["info"][0]["description"] ?? "",
            instruction: data[i]["info"][0]["instruction"] ?? "",
            publisher: data[i]["info"][0]["parameter"][2]["value"] ?? "?",
            contact: data[i]["info"][0]["contact"] ?? "",
            web: data[i]["info"][0]["web"] ?? "",
            areaList: generateAreaList(i),
            //area: data[i]["info"][0]["area"][0]["areaDesc"],
            //geocodeName: generateGeoCodeNameList(i),
            //geocodeNumber: data[i]["info"][0]["area"][0]["geocode"][0]["value"],
          );
          tempWarnMessageList.add(tempWarnMessage);
        }
      } catch (e) {
        print("Errror wile parsing katwarn Data: " + e.toString());
        katwarnParseStatus = false;
      }
    } else {
      //something went wrong
      print("can not get Katwarn data");
      katwarnStatus = false;
    }

    // GET from BIWAPP
    print("get from Biwapp");
    var urlBiwapp =
        Uri.parse('https://warnung.bund.de/bbk.biwapp/warnmeldungen.json');
    response = await get(urlBiwapp);
    //print("Response status: " + response.statusCode.toString());
    if (response.statusCode == 200) {
      data = jsonDecode(utf8.decode(response.bodyBytes));
      //check status and count messages
      biwappStatus = true;
      biwappMessages = data.length;

      try {
        biwappParseStatus = true;
        // parse Json and create WarnMessage class instances from it
        for (var i = 0; i < data.length; i++) {
          print("[get biwapp data] i= $i länge= ${data.length}");

          List<Geocode> generateGeoCodeList(int i, int s) {
            List<Geocode> tempGeocodeList = [];
            for (var j = 0;
                j <= data[i]["info"][0]["area"][s]["geocode"].length - 1;
                j++) {
              Geocode tempGeocode =
                  Geocode(geocodeName: "", geocodeNumber: ""); //init
              tempGeocode.geocodeName =
                  data[i]["info"][0]["area"][s]["geocode"][j]["valueName"];
              tempGeocode.geocodeNumber =
                  data[i]["info"][0]["area"][s]["geocode"][j]["value"];
              tempGeocodeList.add(tempGeocode);
            }
            return tempGeocodeList;
          }

          List<Area> generateAreaList(int i) {
            List<Area> tempAreaList = [];
            //loop through list of areas
            for (var s = 0; s <= data[i]["info"][0]["area"].length - 1; s++) {
              Area tempArea = Area(areaDesc: "", geocodeList: []); //init clear
              tempArea.areaDesc = data[i]["info"][0]["area"][s]["areaDesc"];
              tempArea.geocodeList = generateGeoCodeList(i, s);
              tempAreaList.add(tempArea);
            }
            return tempAreaList;
          }

          WarnMessage tempWarnMessage = WarnMessage(
            source: "BIWAPP",
            identifier: data[i]["identifier"] ?? "?",
            sender: data[i]["sender"] ?? "?",
            sent: data[i]["sent"] ?? "?",
            status: data[i]["status"] ?? "?",
            messageTyp: data[i]["msgType"] ?? "?",
            scope: data[i]["scope"] ?? "?",
            category: data[i]["info"][0]["category"][0] ?? "?",
            event: data[i]["info"][0]["event"] ?? "?",
            urgency: data[i]["info"][0]["urgency"] ?? "?",
            severity: data[i]["info"][0]["severity"] ?? "?",
            certainty: data[i]["info"][0]["certainty"] ?? "?",
            headline: data[i]["info"][0]["headline"] ?? "?",
            description: data[i]["info"][0]["description"] ?? "",
            instruction: data[i]["info"][0]["instruction"] ?? "",
            publisher: data[i]["info"][0]["parameter"][0]["value"] ?? "?", // different to others ["parameter"][0]
            contact: data[i]["info"][0]["contact"] ?? "",
            web: data[i]["info"][0]["web"] ?? "",
            areaList: generateAreaList(i),
            //area: data[i]["info"][0]["area"][0]["areaDesc"],
            //geocodeName: generateGeoCodeNameList(i),
            //geocodeNumber: data[i]["info"][0]["area"][0]["geocode"][0]["value"],
          );
          tempWarnMessageList.add(tempWarnMessage);
        }
      } catch (e) {
        print("Error while parsing biwapp data: " + e.toString());
        biwappParseStatus = false;
      }
    } else {
      //something went wrong
      print("can not get biwwapp data");
      biwappStatus = false;
    }

    // GET from DWD
    print("get from DWD");
    var urlDWDwarnings = Uri.parse(
        'https://warnung.bund.de/bbk.dwd/unwetter.json'); //https://s3.eu-central-1.amazonaws.com/app-prod-static.warnwetter.de/v16/gemeinde_warnings.json
    response = await get(urlDWDwarnings);
    //print("Response status: " + response.statusCode.toString());
    if (response.statusCode == 200) {
      //updates status
      dwdStatus = true;

      data = jsonDecode(utf8.decode(response.bodyBytes));

      //count messages
      dwdMessages = data.length; //TODO: check if this works

      try {
        dwdParseStatus = true;
        for (var i = 0; i <= data.length - 1; i++) {
          List<Geocode> generateGeoCodeList(int i, int s) {
            List<Geocode> tempGeocodeList = [];
            for (var j = 0;
                j <= data[i]["info"][0]["area"][s]["geocode"].length - 1;
                j++) {
              Geocode tempGeocode =
                  Geocode(geocodeName: "", geocodeNumber: ""); //init
              tempGeocode.geocodeName =
                  data[i]["info"][0]["area"][s]["geocode"][j]["valueName"];
              tempGeocode.geocodeNumber =
                  data[i]["info"][0]["area"][s]["geocode"][j]["value"];
              tempGeocodeList.add(tempGeocode);
            }
            return tempGeocodeList;
          }

          List<Area> generateAreaList(int i) {
            List<Area> tempAreaList = [];
            //loop through list of areas
            for (var s = 0; s <= data[i]["info"][0]["area"].length - 1; s++) {
              Area tempArea = Area(areaDesc: "", geocodeList: []); //init clear
              tempArea.areaDesc = data[i]["info"][0]["area"][s]["areaDesc"];
              tempArea.geocodeList = generateGeoCodeList(i, s);
              tempAreaList.add(tempArea);
            }
            return tempAreaList;
          }

          WarnMessage tempWarnMessage = WarnMessage(
            source: "DWD",
            identifier: data[i]["identifier"] ?? "?",
            sender: data[i]["sender"] ?? "?",
            sent: data[i]["sent"] ?? "?",
            status: data[i]["status"] ?? "?",
            messageTyp: data[i]["msgType"] ?? "?",
            scope: data[i]["scope"] ?? "",
            category: data[i]["info"][0]["category"][0] ?? "?",
            event: data[i]["info"][0]["event"] ?? "?",
            urgency: data[i]["info"][0]["urgency"] ?? "?",
            severity: data[i]["info"][0]["severity"] ?? "?",
            certainty: data[i]["info"][0]["certainty"] ?? "?",
            headline: data[i]["info"][0]["headline"] ?? "?",
            description: data[i]["info"][0]["description"] ?? "",
            instruction: data[i]["info"][0]["instruction"] ?? "",
            publisher: data[i]["info"][0]["senderName"] ?? "?",
            contact: data[i]["info"][0]["contact"] ?? "?",
            web: data[i]["info"][0]["web"] ?? "?",
            areaList: generateAreaList(i),
            //area: data[i]["info"][0]["area"][0]["areaDesc"],
            //geocodeName: generateGeoCodeNameList(i),
            //geocodeNumber: data[i]["info"][0]["area"][0]["geocode"][0]["value"],
          );
          tempWarnMessageList.add(tempWarnMessage);
        }
      } catch (e) {
        print("Error while parsing DWD Data: " + e.toString());
        dwdParseStatus = false;
      }
    } else {
      //something went wrong
      print("can not get DWD data");
      dwdStatus = false;
    }

    // GET from HWZ
    print("get from DWD");
    var urlLHPwarnings = Uri.parse(
        'https://warnung.bund.de/bbk.lhp/hochwassermeldungen.json');
    response = await get(urlLHPwarnings);
    //print("Response status: " + response.statusCode.toString());
    if (response.statusCode == 200) {
      //updates status
      lhpStatus = true;

      data = jsonDecode(utf8.decode(response.bodyBytes));

      //count messages
      lhpMessages = data.length; //TODO: check if this works

      try {
        lhpParseStatus = true;
        for (var i = 0; i <= data.length - 1; i++) {
          List<Geocode> generateGeoCodeList(int i, int s) {
            List<Geocode> tempGeocodeList = [];
            for (var j = 0;
            j <= data[i]["info"][0]["area"][s]["geocode"].length - 1;
            j++) {
              Geocode tempGeocode =
              Geocode(geocodeName: "", geocodeNumber: ""); //init
              tempGeocode.geocodeName =
              data[i]["info"][0]["area"][s]["geocode"][j]["valueName"];
              tempGeocode.geocodeNumber =
              data[i]["info"][0]["area"][s]["geocode"][j]["value"];
              tempGeocodeList.add(tempGeocode);
            }
            return tempGeocodeList;
          }

          List<Area> generateAreaList(int i) {
            List<Area> tempAreaList = [];
            //loop through list of areas
            for (var s = 0; s <= data[i]["info"][0]["area"].length - 1; s++) {
              Area tempArea = Area(areaDesc: "", geocodeList: []); //init clear
              tempArea.areaDesc = data[i]["info"][0]["area"][s]["areaDesc"];
              tempArea.geocodeList = generateGeoCodeList(i, s);
              tempAreaList.add(tempArea);
            }
            return tempAreaList;
          }

          WarnMessage tempWarnMessage = WarnMessage(
            source: "LHP",
            identifier: data[i]["identifier"] ?? "?",
            sender: data[i]["sender"] ?? "?",
            sent: data[i]["sent"] ?? "?",
            status: data[i]["status"] ?? "?",
            messageTyp: data[i]["msgType"] ?? "?",
            scope: data[i]["scope"] ?? "",
            category: data[i]["info"][0]["category"][0] ?? "?",
            event: data[i]["info"][0]["event"] ?? "?",
            urgency: data[i]["info"][0]["urgency"] ?? "?",
            severity: data[i]["info"][0]["severity"] ?? "?",
            certainty: data[i]["info"][0]["certainty"] ?? "?",
            headline: data[i]["info"][0]["headline"] ?? "?",
            description: data[i]["info"][0]["description"] ?? "",
            instruction: data[i]["info"][0]["instruction"] ?? "",
            publisher: data[i]["info"][0]["senderName"] ?? "?",
            contact: data[i]["info"][0]["contact"] ?? "?",
            web: data[i]["info"][0]["web"] ?? "?",
            areaList: generateAreaList(i),
            //area: data[i]["info"][0]["area"][0]["areaDesc"],
            //geocodeName: generateGeoCodeNameList(i),
            //geocodeNumber: data[i]["info"][0]["area"][0]["geocode"][0]["value"],
          );
          tempWarnMessageList.add(tempWarnMessage);
        }
      } catch (e) {
        print("Error while parsing LHP Data: " + e.toString());
        lhpParseStatus = false;
      }
    } else {
      //something went wrong
      print("can not get LHP data");
      lhpStatus = false;
    }

    warnMessageList.clear(); //clear List
    warnMessageList = tempWarnMessageList; // transfer temp List in real list
    //print("New WarnList ist here");
    if (showStatusNotification) {
      sendStatusUpdateNotification(true);
    }
  } catch (e) {
    print("Error: " + e.toString());
    dwdStatus = false;
    mowasStatus = false;
    biwappStatus = false;
    katwarnStatus = false;
    lhpStatus = false;
    if (showStatusNotification) {
      sendStatusUpdateNotification(false);
    }
  }
  return "";
}
