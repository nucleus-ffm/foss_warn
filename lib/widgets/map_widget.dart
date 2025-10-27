import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_bounding_box.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/constants.dart' as constants;
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vectorTile;

import '../class/class_area.dart';
import '../class/class_warn_message.dart';
import '../services/alert_api/fpas.dart';
import '../services/api_handler.dart';
import '../services/list_handler.dart';

class MapWidget extends ConsumerStatefulWidget {
  final List<PolygonLayer>? polygonLayers;
  final List<MarkerLayer>? markerLayers;
  final List<TileLayer>? tileLayers;
  final List<Widget>? widgets;
  final MapController mapController;
  final CameraFit initialCameraFit;
  final bool displayAllWarnings;

  const MapWidget({
    super.key,
    this.polygonLayers,
    this.markerLayers,
    this.widgets,
    this.tileLayers,
    required this.mapController,
    required this.initialCameraFit,
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

  static List<PolygonLayer> createPolygonsForMapWarning(WidgetRef ref) {
    List<PolygonLayer> result = [];
    for (WarnMessage wm in mapWarningsList) {
      result.add(
        PolygonLayer(
          polygonCulling: true,
          polygons: Area.createListOfPolygonsForAreas(wm.info.first.area, ref),
        ),
      );
    }
    return result;
  }

  @override
  ConsumerState<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends ConsumerState<MapWidget> {
  Style? _style;

  Future<Style> _readStyle() => StyleReader(
        uri: 'http://10.0.2.2:8000/static/map_style.json',
        // ignore: undefined_identifier
        logger: const vectorTile.Logger.console(),
      ).read();

  Future<void> _initStyle() async {
    try {
      _style = await _readStyle();
    } catch (e, stack) {
      // ignore: avoid_print
      print(e);
      // ignore: avoid_print
      print(stack);
    }
    setState(() {});
  }

  Future<List<WarnMessage>> getAlerts(LatLng coordinates) async {
    var alertApi = ref.watch(alertApiProvider);
    double areaSelectionRadius = 0.01;
    // construct the bounding box around the selected point on the map to fetch
    // the alerts for this area
    BoundingBox boundingBox = BoundingBox(
      minLatLng: LatLng(coordinates.latitude - areaSelectionRadius,
          coordinates.longitude - areaSelectionRadius),
      maxLatLng: LatLng(coordinates.latitude + areaSelectionRadius,
          coordinates.longitude + areaSelectionRadius),
    );
    List<AlertApiResult> results =
        await alertApi.getAlertsForArea(boundingBox: boundingBox);
    print(results);
    List<WarnMessage> alerts = await Future.wait([
      for (var alert in results) ...[
        alertApi.getAlertDetail(
            alertId: alert.alertId, placeSubscriptionId: "no subscription")
      ]
    ]);
    print(alerts);
    return alerts;
  }

  /// build from the given List of alerts a list of ListTiles with the headline
  /// of each alert
  List<ListTile> buildAlertListTile(List<WarnMessage> alerts) {
    List<ListTile> result = [];

    for (var alert in alerts) {
      result.add(
        ListTile(
          title: Text(alert.info.first.headline),
          onTap: () {
            print("Tapped on ${alert.identifier}");
          },
        ),
      );
    }
    return result;
  }

  Future<Widget> alertSelectionSheet(LatLng coordinates) async {
    List<WarnMessage> alerts = await getAlerts(coordinates);
    if (!context.mounted) return const Column();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Current Alerts for this area",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          ...buildAlertListTile(alerts),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initStyle();
  }

  @override
  Widget build(BuildContext context) {
    var userPreferences = ref.watch(userPreferencesProvider);

    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
          initialCameraFit: widget.initialCameraFit,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
          onTap: (tagPosition, latLng) {
            print(LatLng);
            showBottomSheet(
                context: context,
                builder: (context) {
                  return FutureBuilder<Widget>(
                      future: alertSelectionSheet(latLng),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            final Widget data = snapshot.data!;
                            return data;
                          } else {
                            debugPrint(
                                "Error getting system information: ${snapshot.error}");
                            return const Text("Error",
                                style: TextStyle(color: Colors.red));
                          }
                        } else {
                          return Padding(
                            padding: EdgeInsets.all(10),
                            child: const CircularProgressIndicator(),
                          );
                        }
                      });
                });
          }),
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
                  )
                : const SizedBox()
            : const SizedBox(),
        ...widget.polygonLayers ?? [],
        ...widget.markerLayers ?? [],
        ...widget.widgets ?? [],
        const SimpleAttributionWidget(
          source: Text('OpenStreetMap contributors'),
        ),
      ],
    );
  }
}
