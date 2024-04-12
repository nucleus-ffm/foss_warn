import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foss_warn/class/class_NinaPlace.dart';
import 'package:foss_warn/class/class_WarnMessage.dart';
import 'package:foss_warn/widgets/MapWidget.dart';
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
  final MapController mapController = MapController();

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

  List<MarkerLayer> _createMarkerLayer() {
    List<MarkerLayer> result = [];
    for (Place p in myPlaceList) {
      if (p is NinaPlace) {
        result.add(
          MarkerLayer(
            markers: [
              Marker(
                point: p.geocode.latLng,
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

  /// extract hex color value from string and return Color widget
  /// accepts colors in format `#FB8C00`
  /*
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "90" + hexColor;
    } else {
      hexColor = "A0" + "FB8C00";
    }
    return Color(int.parse(hexColor, radix: 16));
  }
  */

  /// create polygon layer for my places alerts
  List<PolygonLayer> _createPolygonLayer() {
    List<PolygonLayer> result = [];
    for (Place p in myPlaceList) {
      for (WarnMessage wm in p.warnings) {
        result.add(
          PolygonLayer(
            polygons: MapWidget.createAllPolygons(wm.info.first.area),
          ),
        );
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(
        initialCameraFit:
            CameraFit.coordinates(padding: EdgeInsets.all(30), coordinates: [
          LatLng(52.815, 7.009),
          LatLng(53.264, 14.326),
          LatLng(48.236, 12.964),
          LatLng(48.704, 7.932),
          LatLng(51.096, 6.746)
        ]),
        mapController: mapController,
        widgets: [buildFilterButtons()],
        polygonLayers: [
          ..._filters[1] ? MapWidget.createPolygonLayer() : [],
          ..._filters[0] ? MapWidget.createPolygonsForMapWarning() : [],
        ],
        markerLayers: [..._createMarkerLayer()],
      ),
    );
  }
}
