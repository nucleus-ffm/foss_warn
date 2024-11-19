import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../class/abstract_Place.dart';
import '../class/class_Area.dart';
import '../class/class_WarnMessage.dart';
import '../main.dart';
import '../services/listHandler.dart';

class MapWidget extends StatefulWidget {
  final List<PolygonLayer>? polygonLayers;
  final List<MarkerLayer>? markerLayers;
  final List<Widget>? widgets;
  final MapController mapController;
  final CameraFit initialCameraFit;
  MapWidget(
      {super.key,
      this.polygonLayers,
      this.markerLayers,
      this.widgets,
      required this.mapController,
      required this.initialCameraFit});

  /// create polygon layer for my places alerts
  static List<PolygonLayer> createPolygonLayer() {
    List<PolygonLayer> result = [];
    for (Place p in myPlaceList) {
      for (WarnMessage wm in p.warnings) {
        result.add(
          PolygonLayer(
            polygons: Area.createListOfPolygonsForAreas(wm.info.first.area),
          ),
        );
      }
    }
    return result;
  }

  static List<PolygonLayer> createPolygonsForMapWarning() {
    List<PolygonLayer> result = [];
    for (WarnMessage wm in mapWarningsList) {
      result.add(
        PolygonLayer(
          polygonCulling: true,
          polygons: Area.createListOfPolygonsForAreas(wm.info.first.area),
        ),
      );
    }
    return result;
  }

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  /// extract hex color value from string and return Color widget
  /// accepts colors in format `#FB8C00`
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "90" + hexColor;
    } else {
      hexColor = "A0" + "FB8C00";
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
          initialCameraFit: widget.initialCameraFit,
          interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate)),
      children: [
        TileLayer(
          urlTemplate: userPreferences.osmTileServerULR,
          userAgentPackageName: userPreferences.httpUserAgent,
          tileBuilder:
              (BuildContext context, Widget tileWidget, TileImage tile) {
            // there is not build in dark mode with the tiles form osm.org therefore we
            // have to manipulate the incoming tiles with some color magic
            return userPreferences.selectedThemeMode == ThemeMode.dark ||
                    (userPreferences.selectedThemeMode == ThemeMode.system &&
                        MediaQuery.of(context).platformBrightness ==
                            Brightness.dark)
                ? ColorFiltered(
                    colorFilter: userPreferences.mapDarkMode, child: tileWidget)
                : ColorFiltered(
                    colorFilter: userPreferences.mapLightMode,
                    child: tileWidget);
          },
        ),
        ...widget.polygonLayers ?? [],
        ...widget.markerLayers ?? [],
        ...widget.widgets ?? [],
        SimpleAttributionWidget(source: Text('OpenStreetMap contributors')),
      ],
    );
  }
}
