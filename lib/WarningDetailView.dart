import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foss_warn/SettingsView.dart';
import 'class/class_WarnMessage.dart';
import 'class/class_Area.dart';
import 'class/class_Geocode.dart';
import 'services/markWarningsAsRead.dart';
import 'services/urlLauncher.dart';

import 'package:share_plus/share_plus.dart';

class DetailScreen extends StatefulWidget {
  final WarnMessage warnMessage;
  const DetailScreen({Key? key, required this.warnMessage}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String replaceHTMLTags(String text) {
    return text.replaceAll("<br/>", "\n");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void>? _launched;

    markOneWarningAsReadFromDetailView(widget.warnMessage);

    String formatSentDate(String dateAndTime) {
      // split "sent" String and give date & time formatted and with time lag back
      String returnDate = "";
      int space = dateAndTime.indexOf("T");
      String date = dateAndTime.substring(0, space);

      int year = int.parse(date.substring(0, 4));
      int month = int.parse(date.substring(5, 7));
      int day = int.parse(date.substring(8, 10));

      String time = dateAndTime.substring(space + 1, space + 9);
      String timeLag =
          dateAndTime.substring(dateAndTime.length - 5, dateAndTime.length);
      String timeLagHours = timeLag.substring(1, 2);

      int seconds = int.parse(time.substring(time.length - 2, time.length));
      int minutes = int.parse(time.substring(time.length - 5, time.length - 3));
      int hours = int.parse(time.substring(0, 2));

      String secondsAsString = "";
      String minutesAsString = "";
      String hoursAsString = "";

      if (seconds.toString().length == 1) {
        secondsAsString = "0" + seconds.toString();
      } else {
        secondsAsString = seconds.toString();
      }
      if (minutes.toString().length == 1) {
        minutesAsString = "0" + minutes.toString();
      } else {
        minutesAsString = minutes.toString();
      }
      if (hours.toString().length == 1) {
        hoursAsString = "0" + hours.toString();
      } else {
        hoursAsString = hours.toString();
      }

      String correctDate =
          day.toString() + "." + month.toString() + "." + year.toString();
      String correctFormatTime = hoursAsString +
          ":" +
          minutesAsString +
          ":" +
          secondsAsString +
          " Uhr";

      return correctDate + " - " + correctFormatTime;
    }

    String translateMessageTyp(String text) {
      if (text == "Update") {
        return "Update";
      } else if (text == "Cancel") {
        return "Entwarnung";
      } else if (text == "Alert") {
        return "Achtung";
      } else {
        return text;
      }
    }

    String translateMessageSeverity(String text) {
      if (text == "Minor") {
        return "gering";
      } else if (text == "Moderate") {
        return "Mittel";
      } else if (text == "Extrem") {
        return "Extrem";
      } else if (text == "Severe") {
        return "Schwer";
      } else {
        return text;
      }
    }

    String translateMessageStatus(String text) {
      if (text == "Actual") {
        return "real";
      } else {
        return text;
      }
    }

    String translateMessageUrgency(String text) {
      if (text == "Immediate") {
        return "unmittelbar";
      } else {
        return text;
      }
    }

    String translateMessageCertainty(String text) {
      if (text == "Observed") {
        return "beobachtet";
      } else {
        return text;
      }
    }

    List<String> generateAreaDescList() {
      List<String> tempList = [];
      for (Area myArea in widget.warnMessage.areaList) {
        tempList.add(myArea.areaDesc);
      }
      return tempList;
    }

    List<String> generateGeocodeNameList() {
      List<String> tempList = [];
      for (Area myArea in widget.warnMessage.areaList) {
        for (Geocode myGeocode in myArea.geocodeList) {
          tempList.add(myGeocode.geocodeName);
        }
      }
      return tempList;
    }

    void shareWarning(BuildContext context, String shareText) async {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(shareText,
          subject: "Test",
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Mehr Infos zu: "),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            tooltip: "Meldung teilen",
              onPressed: () {
                final String shareText = widget.warnMessage.headline +
                    "\n\nMeldung vom: " +
                    formatSentDate(widget.warnMessage.sent) +
                    "\n\nBetroffene Region(en): " + generateAreaDescList().toString().substring(
                    1, generateAreaDescList().toString().length - 1) +
                    "\n\nBeschreibung:\n" +
                    replaceHTMLTags(widget.warnMessage.description) +
                    " \n\nHandlungsempfehlung:\n" +
                    replaceHTMLTags(widget.warnMessage.instruction) +
                    "\n\nQuelle der Meldung:\n " +
                    widget.warnMessage.publisher +
                    "\n\n-- mit stolz geteilt aus aus FOSS Warn --";
                shareWarning(context, shareText);
              },
              icon: Icon(Icons.share))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.warnMessage.headline,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Meldung vom: " + formatSentDate(widget.warnMessage.sent),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(Icons.tag),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Tags:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      color: Colors.deepPurple,
                      child: Text(
                        "Art: " + widget.warnMessage.event,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      color: Colors.red,
                      child: Text(
                          "Typ: " +
                              translateMessageTyp(
                                  widget.warnMessage.messageTyp),
                          style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      color: Colors.orange[800],
                      child: Text(
                        "Warnstufe: " +
                            translateMessageSeverity(
                                widget.warnMessage.severity),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              showExtendedMetaData
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                color: Colors.green,
                                child: Text(
                                  "Dringlichkeit: " +
                                      translateMessageUrgency(
                                          widget.warnMessage.urgency),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                padding: EdgeInsets.all(5),
                                color: Colors.blueGrey,
                                child: Text(
                                  "Lage: " +
                                      translateMessageCertainty(
                                          widget.warnMessage.certainty),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                padding: EdgeInsets.all(5),
                                color: Colors.amber,
                                child: Text(
                                    "Bereich: " + widget.warnMessage.scope),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                color: Colors.lightBlue[200],
                                child: Text(
                                    "ID: " + widget.warnMessage.identifier),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                padding: EdgeInsets.all(5),
                                color: Colors.orangeAccent,
                                child: Text(
                                    "Sender: " + widget.warnMessage.sender),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                color: Colors.greenAccent,
                                child: Text("Status: " +
                                    translateMessageStatus(
                                        widget.warnMessage.status)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    )
                  : SizedBox(),
              Row(
                children: [
                  Icon(Icons.map),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Betroffene Region:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 2,
              ),
              SelectableText(
                  generateAreaDescList().toString().substring(
                      1, generateAreaDescList().toString().length - 1),
                  style: TextStyle(
                    fontSize: 15,
                  )),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Icon(Icons.location_city),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Betroffene Orte:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 2,
              ),
              SelectableText(generateGeocodeNameList().toString().substring(
                  1, generateGeocodeNameList().toString().length - 1)),
              SizedBox(
                height: 10,
              ),
              Row(children: [
                Icon(Icons.description),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "Beschreibung:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ]),
              SizedBox(
                height: 2,
              ),
              SelectableText(replaceHTMLTags(widget.warnMessage.description)),
              SizedBox(
                height: 5,
              ),
              widget.warnMessage.instruction != ""
                  ? Row(
                      children: [
                        Icon(Icons.shield),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Handlungsempfehlung:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    )
                  : SizedBox(),
              SizedBox(
                height: 2,
              ),
              widget.warnMessage.instruction != ""
                  ? SelectableText(
                      replaceHTMLTags(widget.warnMessage.instruction))
                  : SizedBox(),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(Icons.source),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Quelle der Meldung:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  )
                ],
              ),
              Text(widget.warnMessage.publisher),
              SizedBox(
                height: 10,
              ),
              widget.warnMessage.contact != ""
                  ? Row(
                      children: [
                        Icon(Icons.web),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Kontakt und Webseite:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    )
                  : widget.warnMessage.web != ""
                      ? Row(
                          children: [
                            Icon(Icons.web),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Webseite:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        )
                      : SizedBox(),
              SizedBox(
                height: 2,
              ),
              widget.warnMessage.contact != ""
                  ? Row(
                      children: [
                        Icon(Icons.call),
                        SizedBox(
                          width: 5,
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: TextButton(
                            onPressed: () {
                              _launched =
                                  makePhoneCall(widget.warnMessage.contact);
                            },
                            child: Text(
                              replaceHTMLTags(widget.warnMessage.contact),
                            ),
                          ),
                        )
                      ],
                    )
                  : SizedBox(),
              widget.warnMessage.web != ""
                  ? Row(
                      children: [
                        Icon(Icons.open_in_new),
                        SizedBox(
                          width: 5,
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: TextButton(
                            onPressed: () {
                              _launched =
                                  launchUrlInBrowser(widget.warnMessage.web);
                            },
                            child: Text(
                              replaceHTMLTags(widget.warnMessage.web),
                            ),
                          ),
                        )
                      ],
                    )
                  : SizedBox(),

            ],
          ),
        ),
      ),
    );
  }
}
