import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foss_warn/class/class_NinaPlace.dart';
import 'package:foss_warn/class/class_WarnMessage.dart';
import 'package:foss_warn/widgets/MapWidget.dart';
import 'package:foss_warn/widgets/VectorMapWidget.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../class/abstract_Place.dart';
import '../services/listHandler.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  Map<String, bool> filterChips = {"map_view_filter_chip_all_alerts": false, "map_view_filter_chip_my_alerts": true};

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

  String findLabelForChip(String key) {
    switch (key) {
      case "map_view_filter_chip_all_alerts":
        return AppLocalizations.of(context)!.main_nav_bar_my_places;
      case "map_view_filter_chip_my_alerts":
        return AppLocalizations.of(context)!.main_nav_bar_all_warnings;
    }
    return "Error";
  }

  Widget buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text("Filter by:", style: Theme.of(context).textTheme.bodyMedium),
          ),
          Row(
            children: filterChips.entries.map((chip) => Padding(
              padding: EdgeInsets.all(1),
              child: FilterChip(
                tooltip: "active filter: show xyz item", //@todo translate
                label: Text(findLabelForChip(chip.key)), //@todo translate
                backgroundColor: Colors.transparent,
                shape: StadiumBorder(side: BorderSide()),
                selected: chip.value,
                onSelected: (bool value) {
                  setState(() {
                    filterChips.update(chip.key, (value) => !value);
                  });
                },
              ),
            )).toList(),
          ),
        ],
      )
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget( //vectorMapWidget
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
          ...filterChips["map_view_filter_chip_all_alerts"]! ? MapWidget.createPolygonLayer() : [],
          ...filterChips["map_view_filter_chip_my_alerts"]! ? MapWidget.createPolygonsForMapWarning() : [],
        ],
        markerLayers: [..._createMarkerLayer()],
      ),
    );
  }
}
