import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/services/api_handler.dart';
import 'package:provider/provider.dart';

import '../widgets/my_place_widget.dart';
import '../services/update_provider.dart';
import '../services/list_handler.dart';
import '../widgets/connection_error_widget.dart';
import 'add_my_place_with_map_view.dart';

class MyPlaces extends StatefulWidget {
  const MyPlaces({super.key});

  @override
  State<MyPlaces> createState() => _MyPlacesState();
}

class _MyPlacesState extends State<MyPlaces> with WidgetsBindingObserver {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (myPlaceList.isEmpty) {
      _loading = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // reload data when app is resumed
    if (state == AppLifecycleState.resumed) {
      debugPrint("App is resumed...");
      reloadData();
    }
  }

  /// load data and call the API function
  load() async {
    //await loadMyPlacesList(); //@todo should not be nessesary
    await callAPI();
    setState(() {
      _loading = false;
    });
  }

  Future<void> reloadData() async {
    setState(() {
      _loading = true;
    });
    //await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading == true) {
      load();
    }
    while (_loading) {
      return Center(
        child: SizedBox(
          height: 70,
          width: 70,
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 4,
          ),
        ),
      );
    }

    return Consumer<Update>(
      builder: (context, counter, child) => RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: reloadData,
        child: Stack(
          fit: StackFit.expand,
          children: [
            //check if myPlaceList is empty, if not show list else show text
            myPlaceList.isNotEmpty
                ? SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 65),
                        child: Column(children: [
                          ConnectionError(),
                          ...myPlaceList
                              .map((place) => MyPlaceWidget(myPlace: place)),
                        ])),
                  )
                : Column(
                    children: [
                      ConnectionError(),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .my_place_no_place_added,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                AppLocalizations.of(context)!
                                    .my_place_no_place_added_text,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            Positioned(
              bottom: 10,
              right: 10,
              child: FloatingActionButton(
                tooltip: AppLocalizations.of(context)!
                    .my_places_view_add_new_place_button_tooltip,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddMyPlaceWithMapView()), //AddMyPlaceView
                  );
                },
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
