import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_bounding_box.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/class/class_user_agent_http_client.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/constants.dart' as constants;
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/services/subscription_handler.dart';
import 'package:foss_warn/widgets/map_widget.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../widgets/dialogs/loading_screen.dart';

class NovatimResponse {
  const NovatimResponse({
    required this.placeId,
    required this.license,
    required this.osmType,
    required this.osmId,
    required this.latitude,
    required this.longitude,
    required this.locationClass,
    required this.type,
    required this.placeRank,
    required this.importance,
    required this.addressType,
    required this.name,
    required this.displayName,
    required this.boundingBox,
  });

  factory NovatimResponse.fromJson(Map<String, dynamic> json) =>
      NovatimResponse(
        placeId: json["place_id"],
        license: json["licence"],
        osmType: json["osm_type"],
        osmId: json["osm_id"],
        latitude: double.parse(json["lat"]),
        longitude: double.parse(json["lon"]),
        locationClass: json["class"],
        type: json["type"],
        placeRank: json["place_rank"],
        importance: json["importance"],
        addressType: json["addresstype"],
        name: json["name"],
        displayName: json["display_name"],
        boundingBox: [
          for (var bound in json["boundingbox"]) ...[
            double.parse(bound),
          ],
        ],
      );

  final int placeId;
  final String license;
  final String osmType;
  final int osmId;
  final double latitude;
  final double longitude;
  final String locationClass;
  final String type;
  final int placeRank;
  final double importance;
  final String addressType;
  final String name;
  final String displayName;
  final List<double> boundingBox;
}

class AddMyPlaceWithMapView extends ConsumerStatefulWidget {
  const AddMyPlaceWithMapView({
    required this.onPlaceAdded,
    super.key,
  });

  final VoidCallback onPlaceAdded;

  @override
  ConsumerState<AddMyPlaceWithMapView> createState() =>
      _AddMyPlaceWithMapViewState();
}

class _AddMyPlaceWithMapViewState extends ConsumerState<AddMyPlaceWithMapView> {
  final MapController mapController = MapController();
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode textInputFocus = FocusNode();

  //List<Place> _allPlacesToShow = [];
  bool _showSearchResultList = false;
  bool _showRadiusSlider = false;
  List<NovatimResponse> searchResult = [];
  String _selectedPlaceName = "";

  Polygon? selectedPlacePolygon; // the polygon around the selected place
  late BoundingBox boundingBox;
  double placeRadius = 10; // radius of the polygon in km
  double radiusSliderMinValue = 1; // min radius of the slider
  late double radiusSliderMaxValue; // max radio of the slider
  LatLng? currentPlaceLatLng; // the coordinates of the current selected place
  Place? currentPlaceToAdd; // the currently selected place
  int numberOfEdgesPolygon =
      4; // defines how many edges the circle polygon should have
  double cameraPadding =
      50; // padding around the polygon when centering the map

  @override
  void initState() {
    super.initState();

    var userPreferences = ref.read(userPreferencesProvider);
    radiusSliderMaxValue =
        userPreferences.maxSizeOfSubscriptionBoundingBox.toDouble();
  }

  /// calculate a polygon with [numberOfEdges] with
  /// the [radius] (in km) around the given [center]-point
  ///
  /// use the Haversine formula to calculate the distance on the earth surface
  /// see https://en.wikipedia.org/wiki/Haversine_formula
  List<LatLng> calculatePolygonCoordinates(
    LatLng center,
    double radius,
    int numberOfEdges,
  ) {
    const earthRadius = 6371; // Radius of the earth in km

    List<LatLng> polygonPoints = [];
    double angleIncrement = 2 * pi / numberOfEdges;

    double lat1Rad = degreesToRadians(center.latitude);
    double lon1Rad = degreesToRadians(center.longitude);

    for (int i = 1; i < numberOfEdges + 1; i++) {
      double angle = i * angleIncrement;

      double lat2Rad = asin(
        sin(lat1Rad) * cos(radius / earthRadius) +
            cos(lat1Rad) * sin(radius / earthRadius) * cos(angle),
      );
      double lon2Rad = lon1Rad +
          atan2(
            sin(angle) * sin(radius / earthRadius) * cos(lat1Rad),
            cos(radius / earthRadius) - sin(lat1Rad) * sin(lat2Rad),
          );

      double lat2 = radiansToDegrees(lat2Rad);
      double lon2 = radiansToDegrees(lon2Rad);

      polygonPoints.add(LatLng(lat2, lon2));
    }

    return polygonPoints;
  }

  /// calculate a bounding box on the map with the Haversine formula
  List<LatLng> calculateSquareCoordinates(
    LatLng center,
    double radius,
    int numEdge,
  ) {
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
      minLatLng: southWest,
      maxLatLng: northEast,
    );

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
    List<LatLng> circlePolygonPoints = calculateSquareCoordinates(
      currentPlaceLatLng!,
      placeRadius,
      numberOfEdgesPolygon,
    );

    // move the camera to perfect fit the polygon
    mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(circlePolygonPoints),
        padding: EdgeInsets.all(cameraPadding),
      ),
    );
    // create polygon around place
    selectedPlacePolygon = Polygon(
      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
      points: circlePolygonPoints,
    );
  }

  void createBoundingBoxPolygon(List<LatLng> points) {
    // move the camera to perfect fit the polygon
    mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: EdgeInsets.all(cameraPadding),
      ),
    );
    // create polygon around place
    selectedPlacePolygon = Polygon(
      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
      points: points,
    );
  }

  Future<List<NovatimResponse>> requestNovatimData(
    String requestString,
  ) async {
    Uri requestURL = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$requestString&format=json&featureType=city",
    );

    UserAgentHttpClient client =
        UserAgentHttpClient(constants.httpUserAgent, http.Client());

    Response response = await client.get(
      requestURL,
      headers: {"Content-Type": "application/json"},
    );
    var searchData =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return List.from([
      for (var searchResult in searchData) ...[
        NovatimResponse.fromJson(searchResult),
      ],
    ]);
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
    var localizations = context.localizations;
    var theme = Theme.of(context);
    var mediaQuery = MediaQuery.of(context);

    return Scaffold(
      // set to false to prevent jumping of the radiusSlider Widget
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(localizations.add_new_place),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            top: 0,
            child: MapWidget(
              //vector
              mapController: mapController,
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
              polygonLayers: [
                selectedPlacePolygon != null
                    ? PolygonLayer(
                        polygons: [selectedPlacePolygon!],
                      )
                    : const PolygonLayer(polygons: []),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: SizedBox(
              width: mediaQuery.size.width,
              height: 80,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  focusNode: textInputFocus,
                  controller: textEditingController,
                  cursorColor: theme.colorScheme.secondary,
                  autofocus: true,
                  style: theme.textTheme.titleMedium,
                  decoration: InputDecoration(
                    fillColor: theme.colorScheme.secondaryContainer,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        textEditingController.clear();
                        setState(() {
                          selectedPlacePolygon = null;
                          _showRadiusSlider = false;
                        });
                      },
                    ),
                    filled: true,
                    labelText: localizations.add_new_place_place_name,
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
                        text: localizations
                            .add_my_place_with_map_loading_screen_searching,
                      );
                      try {
                        // request data from nominatim
                        searchResult = await requestNovatimData(
                          textEditingController.text,
                        );

                        // show error if there is no result
                        if (searchResult.isEmpty) {
                          if (!context.mounted) return;

                          LoadingScreen.instance().showResult(
                            text: localizations
                                .add_my_place_with_map_loading_screen_search_no_result_found,
                          );
                        } else {
                          // hide the loading screen again
                          LoadingScreen.instance().hide();
                        }
                      } catch (e) {
                        debugPrint("Novatim search failed: ${e.toString()}");
                        ErrorLogger.writeErrorLog(
                          "AddMyPlaceWithMapView.dart",
                          "Error while requesting NovatimData",
                          e.toString(),
                        );
                        if (!context.mounted) return;
                        LoadingScreen.instance().showResult(
                          text: localizations
                              .add_my_place_with_map_loading_screen_search_error,
                        );
                      }
                    }

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
                width: mediaQuery.size.width,
                height: searchResult.length * 70 < 300
                    ? searchResult.length * 70
                    : 300,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    color: theme.colorScheme.secondaryContainer,
                  ),
                  margin: const EdgeInsets.only(left: 8, right: 8),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: searchResult
                          .map(
                            (place) => Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ListTile(
                                leading: const Icon(Icons.place),
                                title: Text(
                                  place.displayName,
                                  style: theme.textTheme.titleMedium,
                                ),
                                onTap: () {
                                  setState(() {
                                    textEditingController.text =
                                        place.displayName;
                                  });

                                  currentPlaceLatLng = LatLng(
                                    place.latitude,
                                    place.longitude,
                                  );

                                  _selectedPlaceName = place.name;
                                  setState(() {
                                    FocusScope.of(context)
                                        .unfocus(); // hide keyboard
                                    _showRadiusSlider = true;
                                    _showSearchResultList = false;
                                    createPolygon();
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
                width: mediaQuery.size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      color: theme.colorScheme.secondaryContainer,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            localizations
                                .add_my_place_with_map_select_area_size,
                            style: theme.textTheme.labelLarge,
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
                              Text("${placeRadius.toInt()} km"),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_selectedPlaceName != "" &&
                                selectedPlacePolygon != null) {
                              await subscribeForArea(
                                boundingBox: boundingBox,
                                selectedPlaceName: _selectedPlaceName,
                                context: context,
                                ref: ref,
                              );
                              widget.onPlaceAdded();
                            } else {
                              debugPrint(
                                "Error_selectedPlaceName or selectedPlacePolygon is null",
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                          child: Text(
                            localizations
                                .add_my_place_with_map_add_place_button,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
