import 'package:latlong2/latlong.dart';

import 'class_ErrorLogger.dart';

class BoundingBox {
    LatLng min_latLng;
    LatLng max_latLng;

    BoundingBox(
        {required this.min_latLng, required this.max_latLng});

    factory BoundingBox.fromJson(Map<String, dynamic> json) {
        /// create new warnMessage objects from saved data

        return BoundingBox(
            min_latLng: LatLng(json['min_latLng']['coordinates'][0], json['min_latLng']['coordinates'][1]), //@todo
            max_latLng: LatLng(json['max_latLng']['coordinates'][0], json['max_latLng']['coordinates'][1])

        );
    }

    Map<String, dynamic> toJson() {
        try {
            return {
                'min_latLng': min_latLng,
                'max_latLng': max_latLng,
            };
        } catch (e) {
            print("Error BoundingBox to json: " + e.toString());
            ErrorLogger.writeErrorLog(
                "class_BoundingBox.dart", "Can not serialize BoundingBox", e.toString());
            return {};
        }
    }
}