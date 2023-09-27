import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/main.dart';
import 'package:provider/provider.dart';

import '../class/abstract_Place.dart';
import '../services/locationService.dart';
import '../services/updateProvider.dart';
import '../views/MyPlaceDetailView.dart';
import 'dialogs/MetaInfoForPlaceDialog.dart';

class MyCurrentLocationPlaceWidget extends StatefulWidget {
  const MyCurrentLocationPlaceWidget({Key? key}) : super(key: key);

  @override
  State<MyCurrentLocationPlaceWidget> createState() =>
      _MyCurrentLocationPlaceWidgetState();
}

class _MyCurrentLocationPlaceWidgetState
    extends State<MyCurrentLocationPlaceWidget> {
  Place? myPlace;

  String checkForWarnings(BuildContext context, Place myPlace) {
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

  // update the current location and load warnings
  Future<void> updatePlace() async {
    await updateCurrentPlace(context);
    setState(() {
      // update myPlace
      myPlace = userPreferences.currentPlace;
    });
    // call api
    await myPlace?.callAPIAndGetWarnings();
    setState(() {
      // update myPlace
      myPlace = userPreferences.currentPlace;
    });
  }

  @override
  void initState() {
    myPlace = userPreferences.currentPlace;
    updatePlace();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Consumer<Update>(
      builder: (context, counter, child) => Card(
        color: Colors.deepOrangeAccent,
        child: InkWell(
          onLongPress: () {},
          onTap: () {
            if (myPlace != null) {
              if (myPlace!.countWarnings != 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MyPlaceDetailScreen(myPlace: myPlace!)),
                );
              }
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
                    myPlace != null
                        ? IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return MetaInfoForPlaceDialog(
                                      myPlace: myPlace!);
                                },
                              );
                            },
                            icon: Icon(Icons.pin_drop),
                          )
                        : IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.gps_not_fixed),
                          ),
                    SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      height: 65,
                      width: (MediaQuery.of(context).size.width) * 0.6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              "Your current location:",
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              myPlace != null ? myPlace!.name : "searching...",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          Flexible(
                              child: myPlace != null
                                  ? Text(checkForWarnings(context, myPlace!),
                              )
                                  : Text(""),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                myPlace != null
                    ? Flexible(
                        child: myPlace!.countWarnings ==
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
                            : myPlace!.checkIfAllWarningsAreRead()
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
                                                MyPlaceDetailScreen(
                                                    myPlace: myPlace!),
                                        ),
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
                                                MyPlaceDetailScreen(
                                                    myPlace: myPlace!),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      Icons.warning,
                                      color: Colors.white,
                                    ),
                                  ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
