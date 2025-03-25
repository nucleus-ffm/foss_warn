import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/services/api_handler.dart';
import 'package:foss_warn/services/warnings.dart';

import '../widgets/my_place_widget.dart';
import '../services/list_handler.dart';
import '../widgets/connection_error_widget.dart';

class MyPlacesView extends ConsumerStatefulWidget {
  const MyPlacesView({
    required this.onAddPlacePressed,
    required this.onPlacePressed,
    super.key,
  });

  final VoidCallback onAddPlacePressed;
  final void Function(String placeSubscriptionId) onPlacePressed;

  @override
  ConsumerState<MyPlacesView> createState() => _MyPlacesState();
}

class _MyPlacesState extends ConsumerState<MyPlacesView>
    with WidgetsBindingObserver {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (ref.read(myPlacesProvider).isEmpty) {
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
  Future<void> load() async {
    //await loadMyPlacesList(); //@todo should not be nessesary
    await callAPI(
      alertApi: ref.read(alertApiProvider),
      warningService: ref.read(warningsProvider.notifier),
      places: ref.read(myPlacesProvider),
    );
    setState(() {
      _loading = false;
    });
  }

  Future<void> reloadData() async {
    setState(() {
      _loading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;

    var places = ref.watch(myPlacesProvider);

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
          places.isNotEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 65),
                    child: Column(
                      children: [
                        const ConnectionError(),
                        ...places.map(
                          (place) => MyPlaceWidget(
                            place: place,
                            onPressed: widget.onPlacePressed,
                          ),
                        ),
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
              onPressed: widget.onAddPlacePressed,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
