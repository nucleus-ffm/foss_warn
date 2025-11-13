import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/constants.dart' as constants;

import '../class/class_area.dart';
import '../class/class_warn_message.dart';
import '../services/list_handler.dart';

class MapWidget extends ConsumerStatefulWidget {
  final List<PolygonLayer>? polygonLayers;
  final List<MarkerLayer>? markerLayers;
  final List<Widget>? widgets;
  final MapController mapController;
  final CameraFit initialCameraFit;

  const MapWidget({
    super.key,
    this.polygonLayers,
    this.markerLayers,
    this.widgets,
    required this.mapController,
    required this.initialCameraFit,
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
