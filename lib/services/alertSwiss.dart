import 'dart:convert';

import '../class/class_WarnMessage.dart';
import '../class/class_Area.dart';
import '../class/class_Geocode.dart';
import 'listHandler.dart';
import 'saveAndLoadSharedPreferences.dart';

import 'package:http/http.dart';

Future callAlertSwissAPI() async {
  String url =
      "https://www.alert.swiss/content/alertswiss-internet/en/home/_jcr_content/polyalert.alertswiss_alerts.actual.json";

  try {
    Response response; //response var for get request
    var data; //var for response data

    List<WarnMessage> tempWarnMessageList = [];
    tempWarnMessageList.clear();
    //print("create new Warn Message List");

    await loadSettings();
    await loadEtags();

    // get overview if warnings exits for myplaces
    response = await get(Uri.parse(url));

    // check if request was sucsessfully
    if (response.statusCode == 200) {
      print("alert swiss status code 200");
      data = jsonDecode(utf8.decode(response.bodyBytes));
      var alerts = data["alerts"];

      for (int i = 0; i < alerts.length; i++) {
        WarnMessage? temp = createWarning(alerts[i]);
        if (temp != null) {
          tempWarnMessageList.add(temp);
        }
      }
      warnMessageList.addAll(tempWarnMessageList); // transfer temp List in real list
    }
  } catch (e) {
    print("Something went wrong: " + e.toString());
  }
}

WarnMessage? createWarning(var data) {
  print("add warning");

  /// generate the instruction
  String generateInstruction(var instructions) {
    String result = "";
    for (int i = 0; i < instructions.length; i++) {
      result += instructions[i]["text"] + "\n \n";
    }
    return result;
  }

  /// generate area List
  List<Area> generateAreaList(var data) {
    List<Area> tempAreaList = [];
    for (int i = 0; i < data.length; i++) {
      tempAreaList.add(
        Area(
          areaDesc: data[i]["description"],
          geocodeList: [
            Geocode(
                geocodeName: data[i]["regions"][0]["region"],
                geocodeNumber: "-1"),
          ],
        ),
      );
    }
    return tempAreaList;
  }

  String addLicense(var pub) {
    if(pub != null) {
      return pub += "\nQuelle: www.alertswiss.ch (CC BY-NC-SA 2.5 CH)";
    } else {
      return "Quelle: www.alertswiss.ch (CC BY-NC-SA 2.5 CH)";
    }
  }

  try {
    WarnMessage tempWarnMessage = WarnMessage(
      source: "Alert Swiss",
      identifier: data["identifier"] ?? "?",
      sender: data["sender"] ?? "?",
      sent: data["sent"] ?? "?",
      status: "?", // missing for alert swiss
      messageTyp: "Alert", // missing
      scope: "?", // missing
      category: data["event"] ?? "?", // missing
      event: data["event"] ?? "?",
      urgency: "?",
      severity: data["severity"] ?? "?",
      certainty: "?", // missing
      effective: "", // missing
      onset: data["onset"] ?? "", // m
      expires: data["expires"] ?? "", // m
      headline: data["title"] ?? "?",
      description: data["description"] ?? "",
      instruction: generateInstruction(data["instruction"] ?? []),
      publisher: addLicense(data["publisherName"]),
      contact: data["contact"] ?? "",
      web: data["link"] ?? "",
      areaList: generateAreaList(data["areas"]),
      //areaList: generateAreaList(i),
      //area: data[i]["info"][0]["area"][0]["areaDesc"],
      //geocodeName: generateGeoCodeNameList(i),
      //geocodeNumber: data[i]["info"][0]["area"][0]["geocode"][0]["value"],
    );

    // don't display tech test alerts
    if(data["technicalTestAlert"] == "true") {
      return null;
    }

    return tempWarnMessage;
  } catch (e) {
    print(
        "something went wrong while paring alert swiss data: " + e.toString());
  }
  return null;
}
