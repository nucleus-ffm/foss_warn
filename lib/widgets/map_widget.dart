import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/constants.dart' as constants;
import 'package:foss_warn/widgets/map_alert_sheet.dart';

import 'package:vector_map_tiles/vector_map_tiles.dart';

import '../class/class_area.dart';
import '../class/class_fpas_place.dart';
import '../class/class_warn_message.dart';
import '../services/alert_api/fpas.dart';
import '../services/list_handler.dart';

class MapWidget extends ConsumerStatefulWidget {
  final List<PolygonLayer>? polygonLayers;
  final List<MarkerLayer>? markerLayers;
  final List<TileLayer>? tileLayers;
  final List<Widget>? widgets;
  final MapController mapController;
  final CameraFit initialCameraFit;
  final bool displayAllWarnings;
  final bool smallAttribution;

  const MapWidget({
    super.key,
    this.polygonLayers,
    this.markerLayers,
    this.widgets,
    this.tileLayers,
    required this.mapController,
    required this.initialCameraFit,
    this.smallAttribution = false,
    this.displayAllWarnings = false,
  });

  /// create polygon layer for my places alerts
  static List<PolygonLayer> createPolygonLayer(
    List<WarnMessage> warnings,
    WidgetRef ref,
  ) {
    List<PolygonLayer> result = [];
    for (var warning in warnings) {
      result.add(
        PolygonLayer(
          polygons:
              Area.createListOfPolygonsForAreas(warning.info.first.area, ref),
        ),
      );
    }
    return result;
  }

  /// create a polygon layer with all subscriptions bounding boxes as polygons
  /// This allows users to easy check which areas they have subscribed for
  static List<PolygonLayer> createSubscriptionsBoundingBox(WidgetRef ref) {
    var subscriptions = ref.read(myPlacesProvider);
    List<Polygon> polygons = [];

    if (subscriptions.isEmpty) {
      return [];
    }

    for (Place p in subscriptions) {
      polygons.add(p.boundingBox.getAsPolygon());
    }

    return [
      PolygonLayer(
        polygonCulling: true,
        polygons: polygons,
      ),
    ];
  }

  @override
  ConsumerState<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends ConsumerState<MapWidget> {
  Style? _style;

  /// Fetch the map style for the all alerts map
  Future<void> _initMapStyle(FPASApi alertAPI) async {
    try {
      _style = await alertAPI.getMapStyle();
    } catch (e) {
      debugPrint(
        "[map_widget.dart] Error while loading map style ${e.toString()}",
      );
      ErrorLogger.writeErrorLog(
        "map_widget.dart",
        "initMapStyle",
        e.toString(),
      );
    }
    setState(() {});
  }

  /// Action that run when the users presses somewhere on the map. If the
  /// displayAllAlerts mode is enable, this fetches all alerts and display a
  /// modalBottomSheet with the alert information
  Future<void> _onMapTapped(tagPosition, latLng) async {
    if (widget.displayAllWarnings) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => MapAlertSheet(latLng, ref),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var userPreferences = ref.watch(userPreferencesProvider);

    // load the map style in case we need it and we don't have it already
    if (widget.displayAllWarnings && _style == null) {
      _initMapStyle(ref.read(alertApiProvider));
    }

    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        initialCameraFit: widget.initialCameraFit,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onLongPress: (tagPosition, latLng) => _onMapTapped(tagPosition, latLng),
      ),
      children: [
        TileLayer(
          urlTemplate: UserPreferences.osmTileServerURL,
          userAgentPackageName: constants.httpUserAgent,
          tileBuilder:
              (BuildContext context, Widget tileWidget, TileImage tile) {
            // there is not build in dark mode with the tiles form osm.org therefore we
            // have to manipulate the incoming tiles with some color magic
            return userPreferences.selectedThemeMode == ThemeMode.dark ||
                    (userPreferences.selectedThemeMode == ThemeMode.system &&
                        MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                ? ColorFiltered(
                    colorFilter: UserPreferences.mapDarkMode,
                    child: tileWidget,
                  )
                : ColorFiltered(
                    colorFilter: UserPreferences.mapLightMode,
                    child: tileWidget,
                  );
          },
        ),
        widget.displayAllWarnings
            ? _style != null
                ? VectorTileLayer(
                    tileProviders: _style!.providers,
                    theme: _style!.theme,
                    sprites: _style!.sprites,
                    maximumZoom: 22,
                    tileOffset: TileOffset.mapbox,
                    layerMode: VectorTileLayerMode.vector,
                    fileCacheTtl: const Duration(minutes: 20),
                  )
                : const SizedBox()
            : const SizedBox(),
        ...widget.polygonLayers ?? [],
        ...widget.markerLayers ?? [],
        ...widget.widgets ?? [],
        // allow to hide the attribution text for widgets
        widget.smallAttribution
            ? const SimpleAttributionWidget(
                source: Text('OSM'),
              )
            : const SimpleAttributionWidget(
                source: Text(
                  'OpenStreetMap contributors',
                ),
              ),
      ],
    );
  }
}
