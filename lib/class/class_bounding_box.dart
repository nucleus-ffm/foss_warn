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
    var minLatLng = (json['min_latLng'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as List<dynamic>));
    var maxLatLng = (json['max_latLng'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as List<dynamic>));

    /// create new warnMessage objects from saved data
    return BoundingBox(
      minLatLng: LatLng(
        minLatLng['coordinates']![1],
        minLatLng['coordinates']![0],
      ), //@todo
      maxLatLng: LatLng(
        maxLatLng['coordinates']![1],
        maxLatLng['coordinates']![0],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        // LatLng.toJson returns [longitude, latitude]
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
