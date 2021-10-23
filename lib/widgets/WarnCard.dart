// widget für die einzelnen Warnungen als Card
import 'package:flutter/material.dart';
import '../services/markWarningsAsRead.dart';
import '../class/class_WarnMessage.dart';
import '../class/class_Area.dart';
import '../class/class_Geocode.dart';
import '../WarningDetailView.dart';
import '../MyPlacesView.dart';
import 'package:provider/provider.dart';
import '../services/updateProvider.dart';
import '../services/listHandler.dart';

class WarnCard extends StatelessWidget {
  final WarnMessage warnMessage;
  const WarnCard({Key? key, required this.warnMessage}) : super(key: key);

  String formatSentDate(String dateAndTime) {
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
    String correctFormatTime =
        hoursAsString + ":" + minutesAsString + ":" + secondsAsString + " Uhr";

    return correctDate + " - " + correctFormatTime;
  }

  String translateCategory(String text) {
    if (text == "Health") {
      return "Gesundheit";
    } else if (text == "Infra") {
      return "Infrastruktur";
    } else if (text == "Fire") {
      return "Feuer";
    } else if (text == "CBRNE") {
      return "CBRNE";
    } else if (text == "Other") {
      return "Sonstiges";
    } else if (text == "Safety") {
      return "Sicherheit";
    } else {
      return text;
    }
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

  Color chooseMessageTypColor(String text) {
    if (text == "Update") {
      return Colors.blueAccent;
    } else if (text == "Cancel") {
      return Colors.green;
    } else if (text == "Alert") {
      return Colors.red;
    } else {
      return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> geocodeNameList = [];
    /*print("Warnug schon gesehen? " +
        myPlaceList
            .any((place) => place.alreadyReadWarnings
                .any((warning) => warning.headline == warnMessage.headline))
            .toString());*/
    updatePrevView() {
      final updater = Provider.of<Update>(context, listen: false);
      updater.updateReadStatusInList();
    }

    List<String> generateGeocodeList() {
      List<String> tempList = [];
      for (Area myArea in warnMessage.areaList) {
        for (Geocode myGeocode in myArea.geocodeList) {
          tempList.add(myGeocode.geocodeName);
        }
      }
      return tempList;
    }
    geocodeNameList = generateGeocodeList();

    return Consumer<Update>(
      builder: (context, counter, child) => Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              readWarnings.contains(warnMessage.identifier)
                  ? IconButton(
                      onPressed: () {
                        markOneWarningAsUnread(warnMessage, context);
                      },
                      icon: Icon(
                        Icons.mark_chat_read,
                        color: Colors.green,
                      ))
                  : IconButton(
                      onPressed: () {
                        markOneWarningAsRead(warnMessage, context);
                      },
                      icon: Icon(
                        Icons.warning_amber_outlined,
                        color: Colors.red,
                      )),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          child: Text(
                            translateCategory(warnMessage.category),
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          color: Colors.amber,
                          padding: EdgeInsets.all(5),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          child: Text(
                            translateMessageTyp(warnMessage.messageTyp),
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          color: chooseMessageTypColor(warnMessage.messageTyp),
                          padding: EdgeInsets.all(5),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: SizedBox(
                            width: 100,
                            child: Text(
                              geocodeNameList.length > 1
                                  ? geocodeNameList.first +
                                      " und " +
                                      (geocodeNameList.length - 1)
                                          .toString() +
                                      " andere"
                                  : geocodeNameList.first,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      warnMessage.headline,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            formatSentDate(warnMessage.sent),
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            warnMessage.sender,
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailScreen(warnMessage: warnMessage)),
                    ).then((value) => updatePrevView());
                  },
                  icon: Icon(Icons.read_more))
            ],
          ),
        ),
      ),
    );
  }
}
