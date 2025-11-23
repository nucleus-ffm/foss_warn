import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/services/warnings.dart';
import 'package:foss_warn/widgets/map_widget.dart';
import 'package:latlong2/latlong.dart';

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  Map<String, bool> filterChips = {
    "map_view_filter_chip_my_alerts": true,
    "map_view_filter_chip_all_alerts": false,
    "map_view_filter_chip_subscriptions": false,
  };

  final MapController mapController = MapController();

  String findLabelForChip(String key) {
    var localizations = context.localizations;

    switch (key) {
      case "map_view_filter_chip_all_alerts":
        return localizations.main_nav_bar_all_warnings;
      case "map_view_filter_chip_my_alerts":
        return localizations.main_nav_bar_my_places;
      case "map_view_filter_chip_subscriptions":
        return localizations.map_view_filter_chips_subscriptions;
    }
    return "Error";
  }

  String findTooltipTranslation(String key, bool value) {
    var localizations = context.localizations;

    if (value) {
      return "${localizations.map_view_filter_chips_tooltip_select_filter}: ${localizations.map_view_filter_chips_tooltip_hide} ${findLabelForChip(key)}";
    }

    return "${localizations.map_view_filter_chips_tooltip_select_filter}: ${localizations.map_view_filter_chips_tooltip_show} ${findLabelForChip(key)}";
  }

  Widget buildFilterButtons() {
    var theme = Theme.of(context);
    var localizations = context.localizations;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              localizations.map_view_filter_chips_title,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filterChips.entries
                  .map(
                    (chip) => Padding(
                      padding: const EdgeInsets.all(1),
                      child: FilterChip(
                        tooltip: findTooltipTranslation(chip.key, chip.value),
                        label: Text(findLabelForChip(chip.key)),
                        backgroundColor: Colors.transparent,
                        shape: const StadiumBorder(side: BorderSide()),
                        selected: chip.value,
                        onSelected: (bool value) {
                          setState(() {
                            filterChips.update(chip.key, (value) => !value);
                          });
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var alerts = ref.watch(processedAlertsProvider);

    return Scaffold(
      body: MapWidget(
        initialCameraFit: const CameraFit.coordinates(
          padding: EdgeInsets.all(30),
          coordinates: [
            LatLng(52.815, 7.009),
            LatLng(53.264, 14.326),
            LatLng(48.236, 12.964),
            LatLng(48.704, 7.932),
            LatLng(51.096, 6.746),
          ],
        ),
        mapController: mapController,
        widgets: [buildFilterButtons()],
        polygonLayers: [
          ...filterChips["map_view_filter_chip_my_alerts"]!
              ? MapWidget.createPolygonLayer(alerts, ref)
              : [],
          ...filterChips["map_view_filter_chip_subscriptions"]!
              ? MapWidget.createSubscriptionsBoundingBox(ref)
              : [],
        ],
        displayAllWarnings: filterChips["map_view_filter_chip_all_alerts"]!,
      ),
    );
  }
}
