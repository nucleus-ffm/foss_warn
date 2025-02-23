import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'class_error_logger.dart';

class BoundingBox {
  LatLng minLatLng;
  LatLng maxLatLng;

  BoundingBox({
    required this.minLatLng,
    required this.maxLatLng,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    /// create new warnMessage objects from saved data
    var minLatitude = json['min_latLng'] as Map<String, List<double>>;
    var maxLatitude = json['max_latLng'] as Map<String, List<double>>;

    return BoundingBox(
      minLatLng: LatLng(
        minLatitude['coordinates']![0],
        minLatitude['coordinates']![1],
      ), //@todo
      maxLatLng: LatLng(
        maxLatitude['coordinates']![0],
        maxLatitude['coordinates']![1],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'min_latLng': minLatLng,
        'max_latLng': maxLatLng,
      };
    } catch (e) {
      debugPrint("Error BoundingBox to json: $e");
      ErrorLogger.writeErrorLog(
        "class_BoundingBox.dart",
        "Can not serialize BoundingBox",
        e.toString(),
      );
      return {};
    }
  }
}
