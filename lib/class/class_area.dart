import 'dart:convert';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import '../main.dart';
import 'class_douglas_peucker.dart';

class Area {
  String description; // Kreisname or general description of the area
  String geoJson; // polygons of the area stored as pure json file

  Area({
    required String areaDesc,
    required this.geoJson,
  }) : description = areaDesc;

  Area.withRegion({
    required String areaDesc,
    required this.geoJson,
  }) : description = areaDesc;

  Area.fromJson(Map<String, dynamic> json)
      : description = json['areaDesc'],
        geoJson = json['geoJson'] ?? "";

  Map<String, dynamic> toJson() =>
      {'areaDesc': description, 'geoJson': geoJson};

  /// create a list of area from the stored json data
  static List<Area> areaListFromJson(var data) {
    List<Area> result = [];
    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        result.add(Area.fromJson(data[i]));
      }
    }
    return result;
  }

  /// create a list of area from CAP Data
  /// converts the CAP geo information into geo json data
  static List<Area> areaListFromJsonWithCAPData(var data) {
    List<Area> result = [];
    if (data != null) {
      // check if data is a list of data or just one entry
      // is just one Area
      if (data is Map<String, dynamic>) {
        // there is just one entry
        Map<String, dynamic> capToGeoJson = _convertCAPGeoInfoToGeoJson(data);

        data.putIfAbsent("geoJson", () => jsonEncode(capToGeoJson));
        result.add(Area.fromJson(data));
      } else {
        // there a multiple entries => multiple areas
        for (int i = 0; i < data.length; i++) {
          Map<String, dynamic> capToGeoJson =
              _convertCAPGeoInfoToGeoJson(data[i]);

          data[i].putIfAbsent("geoJson", () => jsonEncode(capToGeoJson));
          result.add(Area.fromJson(data[i]));
        }
      }
    }
    return result;
  }

  /// converts tha CAP geo information to geo json
  /// { "type": "FeatureCollection",
  ///   "features": [
  ///     { "type": "Feature",
  ///       "geometry": {
  ///         "type": "Polygon",
  ///         "coordinates": [
  ///           [ [100.0, 0.0], [101.0, 0.0], [101.0, 1.0],
  ///             [100.0, 1.0], [100.0, 0.0] ]
  ///         ]
  ///       },
  ///      ]
  ///    }
  static Map<String, dynamic> _convertCAPGeoInfoToGeoJson(
    Map<String, dynamic> data,
  ) {
    Map<String, dynamic> featureCollection = {};
    featureCollection.putIfAbsent("type", () => "FeatureCollection");

    List<Map<String, dynamic>> features = [];

    // convert polygon information into geojson
    if (data.containsKey("polygon")) {
      Map<String, dynamic> feature = {};
      feature.putIfAbsent("type", () => "Feature");

      Map<String, dynamic> polygonFeature = {};

      if (data["polygon"] is List) {
        // the data contain more then one polygon. So we build a multipolygon

        // multiple polygons
        // type MultiPolygon
        polygonFeature.putIfAbsent("type", () => "MultiPolygon");

        List<List<List<List<double>>>> coordinatesList = [];

        List<String> latLng = [];
        List<String> coordinates = [];

        for (int i = 0; i < data["polygon"].length; i += 1) {
          coordinates.clear();
          coordinates = (data["polygon"][i]).split(" ");
          List<List<List<double>>> oneRowCoordinatesOuterList = [];
          List<List<double>> oneRowCoordinates = [];

          for (int j = 0; j < coordinates.length; j += 1) {
            // split with ,
            latLng.clear();
            latLng = coordinates[j].split(",");

            List<double> onePairOfCoordinatesList = [];

            // geo json requires decimal aka double values therefore we
            // parse the value first as double
            onePairOfCoordinatesList.add(double.parse(latLng[1]));
            onePairOfCoordinatesList.add(double.parse(latLng[0]));

            latLng.clear();

            // add the pair to the row List
            oneRowCoordinates.add(onePairOfCoordinatesList);
          }

          // apply douglas peucker to reduce number of polygons
          oneRowCoordinates = DouglasPeucker.simplify(oneRowCoordinates, 0.001);

          oneRowCoordinatesOuterList.clear();
          oneRowCoordinatesOuterList.add(oneRowCoordinates);

          // add the row to the List
          coordinatesList.add(oneRowCoordinatesOuterList);
          // remove not needed storage
        }
        polygonFeature.putIfAbsent("coordinates", () => coordinatesList);

        feature.putIfAbsent("geometry", () => polygonFeature);

        Map<String, dynamic> properties = {};
        properties.putIfAbsent("prop0", () => "value0");
        feature.putIfAbsent("properties", () => properties);
        features.add(feature);
      } else {
        // add type information
        polygonFeature.putIfAbsent("type", () => "Polygon");
        List<List<List<double>>> coordinatesList = [];

        List<List<double>> oneRowCoordinates = [];
        // convert the blank coordinates in CAP format into geojson
        // e.g. "Polygon": "45,-179.99 45,179.99 89.99,179.99 89.99,-179.99 45,-179.99"
        // into
        // { "type": "Polygon",
        //     "coordinates": [
        //         [[45.0, -179.99], [45.0, 179.99], [89.99, 179.9], [89.99, -179.99], [45.0, -179.99]]
        //     ]
        // }
        // split with spaces and remove all [ ] which are maybe a result of .toString @todo
        var coordinates =
            (data["polygon"].toString().replaceAll("[", "").replaceAll("]", ""))
                .split(" ");

        for (var coordinate in coordinates) {
          // split with ,
          List<String> latLng = coordinate.split(",");
          List<double> onePairOfCoordinatesList = [];
          // geo json requires decimal aka double values therefore we
          // parse the value first as double and den convert it again as String
          onePairOfCoordinatesList.add(double.parse(latLng[1]));
          onePairOfCoordinatesList.add(double.parse(latLng[0]));

          // add the pair to the row List
          oneRowCoordinates.add(onePairOfCoordinatesList);
        }

        // apply douglas peucker to reduce number of polygons
        oneRowCoordinates = DouglasPeucker.simplify(oneRowCoordinates, 0.001);

        // add the row to the List
        coordinatesList.add(oneRowCoordinates);

        polygonFeature.putIfAbsent("coordinates", () => coordinatesList);

        feature.putIfAbsent("geometry", () => polygonFeature);

        Map<String, dynamic> properties = {};
        properties.putIfAbsent("prop0", () => "value0");
        feature.putIfAbsent("properties", () => properties);
        features.add(feature);
      }
    }
    featureCollection.putIfAbsent("features", () => features);

    return featureCollection;
  }

  /// create a list with all latLon for all geoJsonFeatures
  static List<LatLng> getListWithAllPolygons(List<Area> areas) {
    List<LatLng> result = [];

    List<Polygon> polygons = createListOfPolygonsForAreas(areas);

    for (Polygon i in polygons) {
      result.addAll(i.points);
    }

    return result;
  }

  /// create a list of polygons from a list of areas
  //  default color: 0xFFB01917
  //  default borderColor: 0xFFFB8C00
  static List<Polygon> createListOfPolygonsForAreas(List<Area> areas) {
    List<Polygon> result = [];
    List<String> debugResult = [];
    try {
      GeoJsonParser myGeoJson = GeoJsonParser(
        defaultPolygonFillColor: const Color(0xFFB01917).withOpacity(0.2),
        defaultPolygonBorderColor: const Color(0xFFFB8C00),
        defaultPolylineStroke: 1,
      );
      for (Area area in areas) {
        myGeoJson.parseGeoJsonAsString(area.geoJson);
        debugResult.add(area.geoJson);
        result.addAll(myGeoJson.polygons);
      }
      return result;
    } catch (e) {
      ErrorLogger.writeErrorLog(
        "MapWidget",
        "Error while parsing geoJson",
        e.toString(),
      );
      appState.error = true;
      return [];
    }
  }
}
