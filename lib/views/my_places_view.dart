import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/services/api_handler.dart';

import '../widgets/my_place_widget.dart';
import '../services/update_provider.dart';
import '../services/list_handler.dart';
import '../widgets/connection_error_widget.dart';
import 'add_my_place_with_map_view.dart';

class MyPlaces extends ConsumerStatefulWidget {
  const MyPlaces({super.key});

  @override
  ConsumerState<MyPlaces> createState() => _MyPlacesState();
}

class _MyPlacesState extends ConsumerState<MyPlaces>
    with WidgetsBindingObserver {
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
    await callAPI(alertApi: ref.read(alertApiProvider));
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
    var localizations = context.localizations;

    ref.watch(updaterProvider); // Just to rebuild on updates

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

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: reloadData,
      child: Stack(
        fit: StackFit.expand,
        children: [
          //check if myPlaceList is empty, if not show list else show text
          myPlaceList.isNotEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 65),
                    child: Column(
                      children: [
                        const ConnectionError(),
                        ...myPlaceList
                            .map((place) => MyPlaceWidget(myPlace: place)),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    const ConnectionError(),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              localizations.my_place_no_place_added,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              localizations.my_place_no_place_added_text,
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
              tooltip:
                  localizations.my_places_view_add_new_place_button_tooltip,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddMyPlaceWithMapView(),
                  ), //AddMyPlaceView
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
