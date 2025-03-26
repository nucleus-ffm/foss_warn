import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/extensions/context.dart';

import '../widgets/my_place_widget.dart';
import '../services/list_handler.dart';
import '../widgets/connection_error_widget.dart';
import 'add_my_place_with_map_view.dart';

class MyPlacesView extends ConsumerStatefulWidget {
  const MyPlacesView({super.key});

  @override
  ConsumerState<MyPlacesView> createState() => _MyPlacesState();
}

class _MyPlacesState extends ConsumerState<MyPlacesView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;

    var places = ref.watch(myPlacesProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        //check if myPlaceList is empty, if not show list else show text
        if (places.isNotEmpty) ...[
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 65),
              child: Column(
                children: [
                  const ConnectionError(),
                  ...places.map((place) => MyPlaceWidget(place: place)),
                ],
              ),
            ),
          ),
        ] else ...[
          Column(
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
        ],
        Positioned(
          bottom: 10,
          right: 10,
          child: FloatingActionButton(
            tooltip: localizations.my_places_view_add_new_place_button_tooltip,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMyPlaceWithMapView(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
