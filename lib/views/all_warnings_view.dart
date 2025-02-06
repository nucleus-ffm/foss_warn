import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_handler.dart';
import '../services/check_for_my_places_warnings.dart';
import '../widgets/connection_error_widget.dart';
import '../class/abstract_place.dart';
import '../class/class_warn_message.dart';
import '../main.dart';
import '../services/list_handler.dart';
import '../widgets/warning_widget.dart';
import '../services/sort_warnings.dart';
import '../services/update_provider.dart';
import '../widgets/no_warnings_in_list.dart';

class AllWarningsView extends ConsumerStatefulWidget {
  const AllWarningsView({super.key});

  @override
  ConsumerState<AllWarningsView> createState() => _AllWarningsViewState();
}

class _AllWarningsViewState extends ConsumerState<AllWarningsView> {
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(updaterProvider); // Just to rebuild on updates

    Future<void> reloadData() async {
      setState(() {
        _loading = true;
      });
    }

    void loadData() async {
      debugPrint("[allWarningsView] Load Data");
      if (userPreferences.showAllWarnings) {
        // call api for the map warnings
        await callMapAPI();
      } else {
        // call (new) api just for my places/ alert swiss
        await callAPI();
      }
      checkForMyPlacesWarnings(true);
      sortWarnings(mapWarningsList);
      setState(() {
        debugPrint("loading finished");
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
      debugPrint("loadOnlyWarningsForMyPlaces");
      List<WarnMessage> warningsForMyPlaces = [];
      for (Place p in myPlaceList) {
        warningsForMyPlaces.addAll(p.warnings);
      }
      return warningsForMyPlaces;
    }

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.secondary,
      onRefresh: reloadData,
      child: myPlaceList.isNotEmpty // check if there is a place saved
          ? userPreferences
                  .showAllWarnings // if warnings that are not in MyPlaces shown
              ? SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(children: [
                    ConnectionError(),
                    mapWarningsList.isEmpty ? NoWarningsInList() : SizedBox(),
                    ...mapWarningsList.map((warnMessage) => WarningWidget(
                        warnMessage: warnMessage, isMyPlaceWarning: false)),
                  ]))
              // else load only the warnings for my place
              : loadOnlyWarningsForMyPlaces() //
                      .isNotEmpty // check if there are warnings for myPlaces
                  ? SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(mainAxisSize: MainAxisSize.max, children: [
                        ConnectionError(),
                        ...loadOnlyWarningsForMyPlaces()
                            .map((warnMessage) => WarningWidget(
                                  warnMessage: warnMessage,
                                  isMyPlaceWarning: true,
                                )),
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
                                      AppLocalizations.of(context)!
                                          .all_warnings_everything_ok,
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold)),
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 200,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  Text(AppLocalizations.of(context)!
                                      .all_warnings_everything_ok_text),
                                  SizedBox(height: 10),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _loading = true;
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .all_warnings_reload,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary),
                                    ),
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
                    ConnectionError(),
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
                              AppLocalizations.of(context)!
                                  .all_warnings_no_places_chosen,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("\n"),
                          Text(AppLocalizations.of(context)!
                              .all_warnings_no_places_chosen_text),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
