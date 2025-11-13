import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/services/warnings.dart';

import '../widgets/my_place_widget.dart';
import '../services/list_handler.dart';
import '../widgets/connection_error_widget.dart';

class MyPlacesView extends ConsumerStatefulWidget {
  const MyPlacesView({
    required this.onAddPlacePressed,
    required this.onPlacePressed,
    required this.onNotificationSelfCheckPressed,
    super.key,
  });

  final VoidCallback onAddPlacePressed;
  final void Function(String placeSubscriptionId) onPlacePressed;
  final VoidCallback onNotificationSelfCheckPressed;

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
    // we have to watch the alertsProvider to keep the timer running
    ref.watch(alertsProvider);

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
                  ConnectionError(
                    onNotificationSelfCheckPressed:
                        widget.onNotificationSelfCheckPressed,
                  ),
                  ...places.map(
                    (place) => MyPlaceWidget(
                      place: place,
                      onPressed: widget.onPlacePressed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ConnectionError(
                onNotificationSelfCheckPressed:
                    widget.onNotificationSelfCheckPressed,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      localizations.all_warnings_no_places_chosen,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      localizations.all_warnings_no_places_chosen_text,
                      textAlign: TextAlign.center,
                    ),
                  ],
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
            onPressed: widget.onAddPlacePressed,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
