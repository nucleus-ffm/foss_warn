import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/views/MyPlaceDetailView.dart';
import '../class/abstract_Place.dart';
import 'dialogs/DeletePlaceDialog.dart';

class MyPlaceWidget extends StatelessWidget {
  final Place myPlace;
  const MyPlaceWidget({Key? key, required this.myPlace}) : super(key: key);

  String checkForWarnings(BuildContext context) {
    print("[MyPlaceWidget] check for warnings");
    if (myPlace.countWarnings > 0) {
      if (myPlace.countWarnings > 1) {
        return AppLocalizations.of(context).my_place_there_are +
            " " +
            myPlace.countWarnings.toString() +
            " " +
            AppLocalizations.of(context).my_place_warnings_more_then_one;
      } else {
        return AppLocalizations.of(context).my_place_there_are +
            " " +
            myPlace.countWarnings.toString() +
            " " +
            AppLocalizations.of(context).my_place_warnings_only_one;
      }
    } else {
      return AppLocalizations.of(context).my_places_no_warning_found;
    }
  }

  Widget build(BuildContext context) {
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
                    width: (MediaQuery.of(context).size.width) * 0.6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            myPlace.getName(),
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
                child: myPlace.countWarnings ==
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
                    : myPlace.checkIfAllWarningsAreRead()
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
