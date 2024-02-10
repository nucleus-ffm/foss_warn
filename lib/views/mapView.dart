import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foss_warn/class/class_NinaPlace.dart';
import 'package:foss_warn/class/class_WarnMessage.dart';
import 'package:foss_warn/main.dart';
import 'package:latlong2/latlong.dart';

import '../class/abstract_Place.dart';
import '../services/listHandler.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  List<bool> _filters = List.generate(2, (index) => false);

  List<ListTile> _createWarningOverviewForPlace(Place place) {
    List<ListTile> result = [];
    for (WarnMessage wm in place.warnings) {
      result.add(ListTile(
        leading: Icon(Icons.warning, color: Colors.red),
        title: Text(wm.info.first.headline),
      ));
    }
    if (place.warnings.isEmpty) {
      result.add(
        ListTile(
          leading: Icon(Icons.check_circle),
          title: Text("Es liegen keine Warnungen vor"), //@todo translate
        ),
      );
    }

    return result;
  }

  Widget buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ToggleButtons(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Alle Warnungen"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Meine Warnungen"),
          ),
          //Icon(Icons.accessibility),
        ],
        isSelected: _filters,
        color: Colors.green,
        selectedColor: Theme.of(context).colorScheme.onPrimary,
        renderBorder: false,
        fillColor: Theme.of(context).colorScheme.primary,
        onPressed: (int index) {
          setState(
            () {
              _filters[index] = !_filters[index];
            },
          );
        },
      ),
    );
  }

  List<PolygonLayer> createPolygonsForMapWarning() {
    List<PolygonLayer> result = [];
    for (WarnMessage wm in mapWarningsList) {
      result.add(
        PolygonLayer(
          polygons: [
            Polygon(
              points: wm.info.first.area.first.polygon,
              color: Colors.orange
                  .withOpacity(0.4), //Color(0xFFFB8C00).withOpacity(0.4),
              borderColor: Color(0xFFFB8C00),
              borderStrokeWidth: 1,
              isFilled: true,
            )
          ],
        ),
      );
    }
    return result;
  }

  List<MarkerLayer> _createMarkerLayer() {
    List<MarkerLayer> result = [];
    for (Place p in myPlaceList) {
      if (p is NinaPlace) {
        result.add(
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                    double.parse(p.geocode.latitude.replaceAll(",", ".")),
                    double.parse(p.geocode.longitude.replaceAll(",", "."))),
                child: InkWell(
                  child: Icon(
                    Icons.place,
                    color: p.warnings.isNotEmpty ? Colors.red : Colors.green,
                    size: 32,
                  ),
                  onTap: () {
                    // print("Place tapped");
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(padding: EdgeInsets.only(top: 22)),
                              ListTile(
                                leading: Icon(
                                  Icons.place,
                                  size: 32,
                                ),
                                title: Text(
                                  p.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Divider(),
                              ),
                              ..._createWarningOverviewForPlace(p),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    }
    return result;
  }

  List<PolygonLayer> _createPolygonLayer() {
    List<PolygonLayer> result = [];
    for (Place p in myPlaceList) {
      for (WarnMessage wm in p.warnings) {
        result.add(
          PolygonLayer(
            polygons: [
              Polygon(
                points: wm.info.first.area.first.polygon,
                color: Colors.orange
                    .withOpacity(0.4), //Color(0xFFFB8C00).withOpacity(0.4),
                borderColor: Color(0xFFFB8C00),
                borderStrokeWidth: 1,
                isFilled: true,
              )
            ],
          ),
        );
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
            initialCenter: LatLng(50.998, 10.107),
            initialZoom: 6.2,
            interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate)),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'de.nucleus.foss_warn',
            tileBuilder:
                (BuildContext context, Widget tileWidget, TileImage tile) {
              // there is not build in dark mode with the tiles form osm.org therefore we
              // have to manipulate the incoming tiles with some color magic
              return userPreferences.selectedThemeMode == ThemeMode.dark ||
                      MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                  ? ColorFiltered(
                      colorFilter: userPreferences.mapDarkMode,
                      child: tileWidget)
                  : ColorFiltered(
                      colorFilter: userPreferences.mapLightMode,
                      child: tileWidget);
            },
          ),
          buildFilterButtons(),
          ..._filters[1] ? _createPolygonLayer() : [],
          ..._filters[0] ? createPolygonsForMapWarning() : [],
          ..._createMarkerLayer(),
          SimpleAttributionWidget(source: Text('OpenStreetMap contributors')),
        ],
      ),
    );
  }
}
