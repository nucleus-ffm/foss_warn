import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../services/apiHandler.dart';
import '../services/checkForMyPlacesWarnings.dart';
import '../widgets/ConnectionErrorWidget.dart';
import '../class/abstract_Place.dart';
import '../class/class_WarnMessage.dart';
import '../main.dart';
import '../services/getData.dart';
import '../services/listHandler.dart';
import '../widgets/WarningWidget.dart';
import '../services/saveAndLoadSharedPreferences.dart';
import '../services/sortWarnings.dart';
import '../services/updateProvider.dart';
import '../widgets/noWarningsInList.dart';

class AllWarningsView extends StatefulWidget {
  const AllWarningsView({Key? key}) : super(key: key);

  @override
  _AllWarningsViewState createState() => _AllWarningsViewState();
}

class _AllWarningsViewState extends State<AllWarningsView> {
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    if (userPreferences.isFirstStart) {
      _loading = true;
      userPreferences.isFirstStart = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> reloadData() async {
      setState(() {
        _loading = true;
      });
    }

    void loadData() async {
      print("[allWarningsView] Load Data");
      if (userPreferences.showAllWarnings) {
        // call (old) api with all warnings
        await getData(false);
      } else {
        // call (new) api just for my places/ alert swiss
        await callAPI();
      }
      checkForMyPlacesWarnings(true);
      sortWarnings(allWarnMessageList);
      loadNotificationSettingsImportanceList();
      setState(() {
        print("loading finished");
        _loading = false;
      });
    }

    if (_loading == true) {
      loadData();
    }
    while (_loading) {
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
      for (Place p in myPlaceList) {
        warningsForMyPlaces.addAll(p.warnings);
      }
      return warningsForMyPlaces;
    }

    return Consumer<Update>(
      builder: (context, counter, child) => RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: reloadData,
        child: myPlaceList.isNotEmpty // check if there is a place saved
            ? userPreferences.showAllWarnings // if warnings that are not in MyPlaces shown
                ? SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(children: [
                      Container(
                        child: ConnectionError(),
                      ),
                      allWarnMessageList.isEmpty
                          ? NoWarningsInList()
                          : SizedBox(),
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
                                    Text(
                                        AppLocalizations.of(context)
                                            !.all_warnings_everything_ok,
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold)),
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 200,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    Text(AppLocalizations.of(context)
                                        !.all_warnings_everything_ok_text),
                                    SizedBox(height: 10),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _loading = true;
                                        });
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)
                                            !.all_warnings_reload,
                                        style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
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
                            Text(
                                AppLocalizations.of(context)
                                    !.all_warnings_no_places_chosen,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("\n"),
                            Text(AppLocalizations.of(context)
                                !.all_warnings_no_places_chosen_text),
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
