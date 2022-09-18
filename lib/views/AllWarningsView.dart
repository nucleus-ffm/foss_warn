import 'package:flutter/material.dart';
import 'package:foss_warn/services/apiHandler.dart';
import 'package:foss_warn/services/checkForMyPlacesWarnings.dart';
import 'package:foss_warn/views/SettingsView.dart';
import 'package:foss_warn/widgets/ConnectionErrorWidget.dart';
import 'package:provider/provider.dart';
import '../class/class_Area.dart';
import '../class/class_Geocode.dart';
import '../class/class_WarnMessage.dart';
import '../main.dart';
import '../services/allPlacesList.dart';
import '../services/getData.dart';
import '../services/listHandler.dart';
import '../widgets/WarningWidget.dart';
import '../services/saveAndLoadSharedPreferences.dart';
import '../services/sortWarnings.dart';
import '../services/updateProvider.dart';

class AllWarningsView extends StatefulWidget {
  const AllWarningsView({Key? key}) : super(key: key);

  @override
  _AllWarningsViewState createState() => _AllWarningsViewState();
}

class _AllWarningsViewState extends State<AllWarningsView> {
  var data;
  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (firstStart) {
      loading = true;
      firstStart = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> reloadData() async {
      setState(() {
        loading = true;
      });
      //
    }

    void loadData() async {
      print("[allWarningsView] Load Data");
      if (showAllWarnings) {
        // call (old) api with all warnings
        data = await getData(false);
      } else {
        // call (new) api just for my places/ alert swiss
        data = await callAPI();
      }
      checkForMyPlacesWarnings(false, true);
      sortWarnings();
      loadNotificationSettingsImportanceList();
      setState(() {
        print("loading finished");
        loading = false;
      });
    }

    if (loading == true) {
      loadData();
    }
    while (loading) {
      // show loading screen
      return Center(
        child: SizedBox(
          height: 70,
          width: 70,
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
            strokeWidth: 4,
          ),
        ),
      );
    }

    /// check all warnings are return only a list with the warnings for
    /// one of my places
    List<WarnMessage> loadOnlyWarningsForMyPlaces() {
      print("loadOnlyWarningsForMyPlaces");
      List<WarnMessage> warningsForMyPlaces = [];
      for (WarnMessage warnMessage in warnMessageList) {
        for (Area myArea in warnMessage.areaList) {
          for (Geocode myGeocode in myArea.geocodeList) {
            if (myPlaceList
                    .any((element) => element.name == myGeocode.geocodeName) ||
                // check for alertSwiss
                myPlaceList.any((element) =>
                    alertSwissPlacesMap[element.name] ==
                    myGeocode.geocodeName)) {
              if (warningsForMyPlaces.contains(warnMessage)) {
                // print("Warn Messsage already in List");
                // warn messeage already in list from geocodename
              } else {
                warningsForMyPlaces.add(warnMessage);
              }
            }
          }
        }
      }
      return warningsForMyPlaces;
    }

    return Consumer<Update>(
      builder: (context, counter, child) => RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: reloadData,
        child: myPlaceList.isNotEmpty // check if there is a place saved
            ? showAllWarnings // if warnings that are not in MyPlaces shown
                ? SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(children: [
                      allWarnMessageList.isEmpty ?
                          Container(
                            child: Text("Es sind keine Warnungen in der Liste"),
                          ): SizedBox(),
                      Container(
                        child: ConnectionError(),
                      ),
                      ...allWarnMessageList
                          .map((warnMessage) =>
                              WarningWidget(warnMessage: warnMessage))
                          .toList(),
                    ]))
                // else load only the warnings for my place
                : loadOnlyWarningsForMyPlaces() //
                        .isNotEmpty // check if there are warnings for myPlaces
                    ? SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child:
                            Column(mainAxisSize: MainAxisSize.max, children: [
                          Container(
                            child: ConnectionError(),
                          ),
                          ...loadOnlyWarningsForMyPlaces()
                              .map((warnMessage) =>
                                  WarningWidget(warnMessage: warnMessage))
                              .toList(),
                        ]),
                      )
                    : Column(
                        // else show a screen with
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Alles ruhig hier",
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold)),
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 200,
                                      color: Colors.green,
                                    ),
                                    Text(
                                        "Es liegen keine Warnungen für Deine Orte vor.\n "),
                                    SizedBox(height: 10),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          loading = true;
                                        });
                                      },
                                      child: Text(
                                        "Neuladen",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: TextButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
            : Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: ConnectionError(),
                      ),
                    ],
                  ),
                      Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Hier gibt es noch nichts zu sehen... ",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  Text("\n"),
                                  Text(
                                      "Bitte wählen Sie mindestens einen Ort aus,"
                                      " für den Sie Warnungen erhalten möchten."
                                      " Oder aktivieren Sie die Anzeige aller Warnungen"),
                                ],
                              ),
                            ),
                          ),
                        )
                ],
              ),
      ),
    );
  }
}
