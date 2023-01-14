import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/views/MyPlaceDetailView.dart';

import '../class/class_Place.dart';
import '../class/class_WarnMessage.dart';
import '../class/class_Geocode.dart';
import '../class/class_Area.dart';
import 'dialogs/DeletePlaceDialog.dart';
import '../services/listHandler.dart';

class MyPlaceWidget extends StatelessWidget {
  final Place myPlace;
  const MyPlaceWidget({Key? key, required this.myPlace}) : super(key: key);

  String checkForWarnings(BuildContext context) {
    print("[MyPlaceWidget] check for warnings");
    int countMessages = 0;
    //print(warnMessageList.length);
    myPlace.warnings.clear();
    for (WarnMessage warnMessage in warnMessageList) {
      for (Area myArea in warnMessage.areaList) {
        for (Geocode myGeocode in myArea.geocodeList) {
          //print(name);
          if (myGeocode.geocodeName == myPlace.name ||
              ((myGeocode.geocodeNumber.length > 5 &&
                      myPlace.geocode.length > 5)
                  ? myGeocode.geocodeNumber.substring(0, 5) ==
                      myPlace.geocode.substring(0, 5)
                  : false)) {
            if (myPlace.warnings.contains(warnMessage)) {
              print("[MyPlaceCard] Warn Messsage already in List");
              //warn messeage already in list from geocodename
            } else {
              countMessages++;
              myPlace.warnings.add(warnMessage);
            }
          }
        }
        if (myArea.areaDesc.contains(myPlace.name)) {
          print(
              "[MyPlaceCard] Area Decs contains myPlace name: " + myPlace.name);
          if (myPlace.warnings.contains(warnMessage)) {
            print("[MyPlaceCard] Warn Messsage already in List");
            //warn messeage already in list from geocodename
          } else {
            print("[MyPlaceCard] add warning für: " + myPlace.name);
            countMessages++;
            myPlace.warnings.add(warnMessage);
          }
        }
      }
    }

    if (countMessages > 0) {
      myPlace.countWarnings = countMessages;
      if (countMessages > 1) {
        return AppLocalizations.of(context).my_place_there_are + " " +
            countMessages.toString() + " " +
            AppLocalizations.of(context).my_place_warnings_more_then_one;
      } else {
        return AppLocalizations.of(context).my_place_there_are +
            countMessages.toString() +
            AppLocalizations.of(context).my_place_warnings_only_one;
      }
    } else {
      return AppLocalizations.of(context).my_places_no_warning_found;
    }
  }

  Widget build(BuildContext context) {
    bool checkIfAllWarningsRead() {
      bool temp = true;
      for (WarnMessage myWarning in myPlace.warnings) {
        if (readWarnings.contains(myWarning.identifier)) {
          // warnung gelesen
        } else {
          // warnung nicht gelesen
          temp = false;
        }
      }
      //print("Alle Meldungen gelesen?: " + temp.toString());
      return temp;
    }

    return Card(
      child: InkWell(
        onLongPress: () {
          print("DeletePlaceDialog opened");
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return DeletePlaceDialog(myPlace: myPlace);
            },
          );
        },
        onTap: () {
          if (myPlace.countWarnings != 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyPlaceDetailScreen(myPlace: myPlace)),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                  Icon(Icons.location_city),
                  SizedBox(
                    width: 20,
                    //width: (MediaQuery.of(context).size.width)-150,
                  ),
                  SizedBox(
                    height: 60,
                    //width: 200,
                    width: (MediaQuery.of(context).size.width)*0.6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                          myPlace.name,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            ),
                        ),
                        Flexible(child: Text(checkForWarnings(context))),
                      ],
                    ),
                  ),
                ],
              ),
              Flexible(
                child:
              myPlace.countWarnings ==
                      0 //check the number of warnings and display check or warning
                  ? TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(15)),
                      onPressed: () {},
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                      ))
                  : checkIfAllWarningsRead()
                      ? TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.grey,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MyPlaceDetailScreen(myPlace: myPlace)),
                            );
                          },
                          child: Icon(
                            Icons.mark_chat_read,
                            color: Colors.white,
                          ),
                        )
                      : TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MyPlaceDetailScreen(myPlace: myPlace)),
                            );
                          },
                          child: Icon(
                            Icons.warning,
                            color: Colors.white,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
