import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foss_warn/class/class_BoundingBox.dart';
import 'package:foss_warn/class/class_ErrorLogger.dart';
import 'package:foss_warn/class/class_FPASPlace.dart';
import 'package:foss_warn/class/class_UserAgentHTTPClient.dart';
import 'package:foss_warn/main.dart';
import 'package:foss_warn/widgets/MapWidget.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../class/abstract_Place.dart';
import '../class/class_NotificationService.dart';
import '../class/class_UnifiedPushHandler.dart';
import '../services/listHandler.dart';
import '../services/updateProvider.dart';
import '../widgets/VectorMapWidget.dart';
import '../widgets/dialogs/LoadingScreen.dart';

class AddMyPlaceWithMapView extends StatefulWidget {
  const AddMyPlaceWithMapView({Key? key}) : super(key: key);

  @override
  State<AddMyPlaceWithMapView> createState() => _AddMyPlaceWithMapViewState();
}

class _AddMyPlaceWithMapViewState extends State<AddMyPlaceWithMapView> {
  final MapController mapController = MapController();
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode textInputFocus = FocusNode();

  //List<Place> _allPlacesToShow = [];
  bool _showSearchResultList = false;
  bool _showRadiusSlider = false;
  List<dynamic> searchResult = [];
  String _selectedPlaceName = "";

  Polygon? selectedPlacePolygon = null; // the polygon around the selected place
  late BoundingBox boundingBox;
  double placeRadius = 10; // radius of the polygon in km
  double radiusSliderMinValue = 1; // min radius of the slider
  double radiusSliderMaxValue = 20; // max radio of the slider
  LatLng? currentPlaceLatLng; // the coordinates of the current selected place
  Place? currentPlaceToAdd; // the currently selected place
  int numberOfEdgesPolygon =
      4; // defines how many edges the circle polygon should have
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

    for (int i = 1; i < numberOfEdges + 1; i++) {
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

  /// calculate a bounding box on the map with the Haversine formula
  List<LatLng> calculateSquareCoordinates(
      LatLng center, double radius, int numEdge) {
    double earthRadius = 6371; // Earth's radius in km

    double lat = center.latitude;
    double lon = center.longitude;

    double north = lat + (radius / earthRadius) * (180 / pi);
    double south = lat - (radius / earthRadius) * (180 / pi);
    double east =
        lon + (radius / earthRadius) * (180 / pi) / cos(lat * pi / 180);
    double west =
        lon - (radius / earthRadius) * (180 / pi) / cos(lat * pi / 180);

    LatLng northWest = LatLng(north, west);
    LatLng northEast = LatLng(north, east);
    LatLng southWest = LatLng(south, west);
    LatLng southEast = LatLng(south, east);

    boundingBox = BoundingBox(
        min_latLng: LatLng(north, west), max_latLng: LatLng(south, east));

    return [northWest, southWest, southEast, northEast];
  }

  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  double radiansToDegrees(double radians) {
    return radians * 180 / pi;
  }

  /// create a circle polygon around the current selected place.
  void createPolygon() {
    /*List<LatLng> circlePolygonPoints = calculatePolygonCoordinates(
        currentPlaceLatLng!, placeRadius, numberOfEdgesPolygon);*/

    List<LatLng> circlePolygonPoints = calculateSquareCoordinates(
        currentPlaceLatLng!, placeRadius, numberOfEdgesPolygon);

    // move the camera to perfect fit the polygon
    mapController.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(circlePolygonPoints),
        padding: EdgeInsets.all(cameraPadding)));
    // create polygon around place
    selectedPlacePolygon = Polygon(
        isFilled: true,
        color: Theme.of(context)
            .colorScheme
            .secondary
            .withOpacity(0.5), //Colors.green.withOpacity(0.5),
        points: circlePolygonPoints);
  }

  void createBoundingBoxPolygon(List<LatLng> points) {
    // move the camera to perfect fit the polygon
    mapController.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: EdgeInsets.all(cameraPadding)));
    // create polygon around place
    selectedPlacePolygon = Polygon(
        isFilled: true,
        color: Theme.of(context)
            .colorScheme
            .secondary
            .withOpacity(0.5), //Colors.green.withOpacity(0.5),
        points: points);
  }

  Future<List<dynamic>> requestNovatimData(String requestString) async {
    Uri requestURL = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=${requestString}&format=json&featureType=city");

    UserAgentHttpClient client =
        UserAgentHttpClient(userPreferences.httpUserAgent, http.Client());

    Response _response = await client.get(
      requestURL,
      headers: {"Content-Type": "application/json"},
    );
    List<dynamic> searchData = jsonDecode(utf8.decode(_response.bodyBytes));
    print(searchData);
    return searchData;
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
                  //vector
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
                    selectedPlacePolygon != null
                        ? PolygonLayer(
                            polygons: [selectedPlacePolygon!],
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
              height: 80,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  focusNode: textInputFocus,
                  controller: textEditingController,
                  cursorColor: Theme.of(context).colorScheme.secondary,
                  autofocus: true,
                  style: Theme.of(context).textTheme.titleMedium,
                  decoration: new InputDecoration(
                    fillColor: Theme.of(context).colorScheme.secondaryContainer,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        textEditingController.clear();
                        setState(() {
                          selectedPlacePolygon = null;
                          _showRadiusSlider = false;
                        });
                      },
                    ),
                    filled: true,
                    labelText:
                        AppLocalizations.of(context)!.add_new_place_place_name,
                  ),
                  onTap: () {
                    setState(() {
                      selectedPlacePolygon = null;
                      _showRadiusSlider = false;
                    });
                  },
                  onSubmitted: (value) async {
                    if (value != "") {
                      LoadingScreen.instance().show(
                          context: context,
                          text: AppLocalizations.of(context)!
                              .add_my_place_with_map_loading_screen_searching);
                      try {
                        // request data from nominatim
                        searchResult = await requestNovatimData(
                            textEditingController.text);

                        // show error if there is no result
                        if (searchResult.isEmpty) {
                          LoadingScreen.instance().show(
                              context: context,
                              text: AppLocalizations.of(context)!
                                  .add_my_place_with_map_loading_screen_search_no_result_found);
                          await Future.delayed(const Duration(seconds: 3));
                        }
                      } catch (e) {
                        print("Novatim search failed: ${e.toString()}");
                        ErrorLogger.writeErrorLog("AddMyPlaceWithMapView.dart",
                            "Error while requesting NovatimData", e.toString());
                        LoadingScreen.instance().show(
                            context: context,
                            text: AppLocalizations.of(context)!
                                .add_my_place_with_map_loading_screen_search_error);
                        await Future.delayed(const Duration(seconds: 3));
                      }
                    }
                    // hide the loading screen again
                    LoadingScreen.instance().hide();

                    setState(() {
                      // show results
                      _showSearchResultList = true;
                      if (currentPlaceLatLng != null) {
                        _showRadiusSlider = true;
                      }
                    });
                  },
                  onChanged: (text) {
                    setState(() {
                      _showSearchResultList = false;
                    });
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: 63,
            child: Visibility(
              visible: _showSearchResultList,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: searchResult.length * 70 < 300
                    ? searchResult.length * 70
                    : 300,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12)),
                      color: Theme.of(context).colorScheme.secondaryContainer),
                  margin: EdgeInsets.only(left: 8, right: 8),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: searchResult
                          .map(
                            (place) => Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ListTile(
                                leading: Icon(Icons.place),
                                //visualDensity:
                                //VisualDensity(horizontal: 0, vertical: -4),
                                title: Text(place["display_name"],
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                onTap: () {
                                  //currentPlaceToAdd = place;
                                  setState(() {
                                    textEditingController.text =
                                        place["display_name"];
                                  });

                                  currentPlaceLatLng = LatLng(
                                      double.parse(place["lat"]),
                                      double.parse(place["lon"]));

                                  List<LatLng> selectedPlaceBoundingBox = [
                                    LatLng(
                                        double.parse(place["boundingbox"][0]),
                                        double.parse(place["boundingbox"][2])),
                                    LatLng(
                                        double.parse(place["boundingbox"][1]),
                                        double.parse(place["boundingbox"][3]))
                                  ];

                                  _selectedPlaceName = place["name"];
                                  setState(() {
                                    FocusScope.of(context)
                                        .unfocus(); // hide keyboard
                                    _showRadiusSlider = true;
                                    _showSearchResultList = false;
                                    createPolygon();
                                    //createBoundingBoxPolygon(selectedPlaceBoundingBox); //@todo
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
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
                              AppLocalizations.of(context)!
                                  .add_my_place_with_map_select_radius,
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
                                Text(placeRadius.toInt().toString() + " km")
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (_selectedPlaceName != "" &&
                                  selectedPlacePolygon != null) {
                                // setup unifiedPush
                                await UnifiedPushHandler.setupUnifiedPush(
                                    context);

                                // subscribe for new area and create new place
                                // with the returned subscription id
                                LoadingScreen.instance().show(
                                    context: context,
                                    text: AppLocalizations.of(context)!
                                        .loading_screen_loading);
                                String subscriptionId = "";
                                try {
                                  subscriptionId =
                                      await UnifiedPushHandler.registerForArea(
                                          context, boundingBox);
                                } catch (e) {
                                  print("Error: ${e.toString()}");
                                  ErrorLogger.writeErrorLog(
                                      "AddMyPlaceWithMapView",
                                      "add place button",
                                      e.toString());
                                  LoadingScreen.instance().show(
                                      context: context,
                                      text: AppLocalizations.of(context)!
                                          .add_my_place_with_map_loading_screen_subscription_error);
                                  await Future.delayed(
                                      const Duration(seconds: 5));
                                }
                                if (subscriptionId != "") {
                                  LoadingScreen.instance().show(
                                      context: context,
                                      text: AppLocalizations.of(context)!
                                          .add_my_place_with_map_loading_screen_subscription_success);
                                  Place newPlace = FPASPlace(
                                      boundingBox: boundingBox,
                                      subscriptionId: subscriptionId,
                                      name: _selectedPlaceName);

                                  setState(() {
                                    final updater = Provider.of<Update>(context,
                                        listen: false);
                                    updater.updateList(newPlace);
                                    // cancel warning of missing places (ID: 3)
                                    NotificationService.cancelOneNotification(
                                        3);
                                    Navigator.of(context).pop();
                                  });
                                }
                                await Future.delayed(
                                    const Duration(seconds: 1));
                                LoadingScreen.instance().hide();
                              } else {
                                print(
                                    "Error_selectedPlaceName or selectedPlacePolygon is null");
                              }
                            },
                            child: Text(AppLocalizations.of(context)!
                                .add_my_place_with_map_add_place_button),
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
