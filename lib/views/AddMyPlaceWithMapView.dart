import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foss_warn/class/class_NinaPlace.dart';
import 'package:foss_warn/widgets/MapWidget.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../class/abstract_Place.dart';
import '../class/class_NotificationService.dart';
import '../services/listHandler.dart';
import '../services/updateProvider.dart';

class AddMyPlaceWithMapView extends StatefulWidget {
  const AddMyPlaceWithMapView({Key? key}) : super(key: key);

  @override
  State<AddMyPlaceWithMapView> createState() => _AddMyPlaceWithMapViewState();
}

class _AddMyPlaceWithMapViewState extends State<AddMyPlaceWithMapView> {
  final MapController mapController = MapController();
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode textInputFocus = FocusNode();

  List<Place> _allPlacesToShow = [];
  bool _showSearchResultList = false;
  bool _showRadiusSlider = false;

  Polygon? circlePolygon = null; // the polygon around the selected place
  double placeRadius = 10; // radius of the polygon in km
  double radiusSliderMinValue = 1; // min radius of the slider
  double radiusSliderMaxValue = 20; // max radio of the slider
  LatLng? currentPlaceLatLng; // the coordinates of the current selected place
  Place? currentPlaceToAdd; // the currently selected place
  int numberOfEdgesPolygon =
      36; // defines how many edges the circle polygon should have
  double cameraPadding =
      50; // padding around the polygon when centering the map

  /// calculate a polygon with [numberOfEdges] with
  /// the [radius] (in km) around the given [center]-point
  ///
  /// use the Haversine formula to calculate the distance on the earth surface
  /// see https://en.wikipedia.org/wiki/Haversine_formula
  List<LatLng> calculatePolygonCoordinates(
      LatLng center, double radius, int numberOfEdges) {
    const earthRadius = 6371; // Radius of the earth in km

    List<LatLng> polygonPoints = [];
    double angleIncrement = 2 * pi / numberOfEdges;
    double lat1Rad = degreesToRadians(center.latitude);
    double lon1Rad = degreesToRadians(center.longitude);

    for (int i = 0; i < numberOfEdges; i++) {
      double angle = i * angleIncrement;

      double lat2Rad = asin(sin(lat1Rad) * cos(radius / earthRadius) +
          cos(lat1Rad) * sin(radius / earthRadius) * cos(angle));
      double lon2Rad = lon1Rad +
          atan2(sin(angle) * sin(radius / earthRadius) * cos(lat1Rad),
              cos(radius / earthRadius) - sin(lat1Rad) * sin(lat2Rad));

      double lat2 = radiansToDegrees(lat2Rad);
      double lon2 = radiansToDegrees(lon2Rad);

      polygonPoints.add(LatLng(lat2, lon2));
    }

    return polygonPoints;
  }

  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  double radiansToDegrees(double radians) {
    return radians * 180 / pi;
  }

  /// create a circle polygon around the current selected place.
  void createPolygon() {
    List<LatLng> circlePolygonPoints = calculatePolygonCoordinates(
        currentPlaceLatLng!, placeRadius, numberOfEdgesPolygon);
    // move the camera to perfect fit the polgon
    mapController.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(circlePolygonPoints),
        padding: EdgeInsets.all(cameraPadding)));
    // create polygon around place
    circlePolygon = Polygon(
        isFilled: true,
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),//Colors.green.withOpacity(0.5),
        points: circlePolygonPoints);
  }

  @override
  void dispose() {
    textInputFocus.dispose();
    mapController.dispose();
    textEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // set to false to prevent jumping of the radiusSlider Widget
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.add_new_place),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: MapWidget(
                  mapController: mapController,
                  initialCameraFit: CameraFit.coordinates(
                    padding: EdgeInsets.all(30),
                    coordinates: [
                      LatLng(52.815, 7.009),
                      LatLng(53.264, 14.326),
                      LatLng(48.236, 12.964),
                      LatLng(48.704, 7.932),
                      LatLng(51.096, 6.746)
                    ],
                  ),
                  polygonLayers: [
                    circlePolygon != null
                        ? PolygonLayer(
                            polygons: [circlePolygon!],
                          )
                        : PolygonLayer(polygons: [])
                  ],
                  /*
                onLongPress: (TapPosition tap, LatLng place) {
                      print("Place: ${place.longitude} ${place.latitude}");
                      setState(() {
                        currentPlaceLatLng = place;
                        createPolygon();
                      });
                    },
                 */
                )),
          ),
          Positioned(
            top: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 500,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  focusNode: textInputFocus,
                  controller: textEditingController,
                  cursorColor: Theme.of(context).colorScheme.secondary,
                  autofocus: true,
                  style: Theme.of(context).textTheme.titleMedium,
                  decoration: new InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        textEditingController.clear();
                      },
                    ),
                    filled: true,
                    labelText:
                        AppLocalizations.of(context)!.add_new_place_place_name,
                  ),
                  onTap: () {
                    setState(() {
                      _showRadiusSlider = false;
                    });
                  },
                  onSubmitted: (value) async {
                    setState(() {
                      if (currentPlaceLatLng != null) {
                        _showRadiusSlider = true;
                      }
                    });
                  },
                  onChanged: (text) {
                    text = text.toLowerCase();
                    setState(() {
                      _showSearchResultList = true;
                      _showRadiusSlider = false;
                      _allPlacesToShow = allAvailablePlacesNames.where((place) {
                        var search = place.name.toLowerCase();
                        return search.contains(text);
                      }).toList();
                    });
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: 70,
            child: Visibility(
              visible: _showSearchResultList,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: Container(
                  margin: EdgeInsets.only(left: 8, right: 8),
                  color: Colors.white54,
                  child: ListView(
                    children: _allPlacesToShow
                        .map(
                          (place) => ListTile(
                            visualDensity:
                                VisualDensity(horizontal: 0, vertical: -4),
                            title: Text(place.name,
                                style: Theme.of(context).textTheme.titleMedium),
                            onTap: () {
                              currentPlaceToAdd = place;
                              setState(() {
                                textEditingController.text = place.name;
                              });

                              if (place is NinaPlace) {
                                currentPlaceLatLng = place.geocode.latLng;

                                setState(() {
                                  FocusScope.of(context)
                                      .unfocus(); // hide keyboard
                                  _showRadiusSlider = true;
                                  _showSearchResultList = false;
                                  createPolygon();
                                });
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              child: Visibility(
                visible: _showRadiusSlider,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)),
                          color:
                              Theme.of(context).colorScheme.secondaryContainer),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "Wähle einen Radius",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    min: radiusSliderMinValue,
                                    max: radiusSliderMaxValue,
                                    value: placeRadius,
                                    onChanged: (value) {
                                      setState(() {
                                        placeRadius = value;
                                        // calcualte the a polygon around the current place
                                        createPolygon();
                                      });
                                    },
                                  ),
                                ),
                                Text(
                                  placeRadius.toInt().toString() + " km"
                                )

                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (currentPlaceToAdd != null) {
                                setState(() {
                                  final updater = Provider.of<Update>(context,
                                      listen: false);
                                  updater.updateList(currentPlaceToAdd!);
                                  // cancel warning of missing places (ID: 3)
                                  NotificationService.cancelOneNotification(3);
                                  Navigator.of(context).pop();
                                });
                              }
                            },
                            child: Text("Ort hinzufügen"),
                            style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
