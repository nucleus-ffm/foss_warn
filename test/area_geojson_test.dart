import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/class/class_area.dart';

Map<String, dynamic> geoJsonOf(Area area) =>
    jsonDecode(area.geoJson) as Map<String, dynamic>;

Map<String, dynamic> singleGeometry(Area area) {
  final features = geoJsonOf(area)["features"] as List<dynamic>;
  final feature = features.single as Map<String, dynamic>;
  return feature["geometry"] as Map<String, dynamic>;
}

void main() {
  group('CAP polygon to GeoJSON', () {
    test('converts one polygon and swaps to lon/lat order', () {
      // CAP writes "lat,lon" pairs, GeoJSON expects [lon, lat]. Getting this
      // backwards puts every alert polygon somewhere else on the map.
      final area = Area.areaFromJsonWithCAPData({
        "areaDesc": "Kreis Musterstadt",
        "polygon": "50.0,8.0 50.0,9.0 51.0,9.0 50.0,8.0",
      });

      expect(area.description, "Kreis Musterstadt");
      expect(geoJsonOf(area)["type"], "FeatureCollection");

      final geometry = singleGeometry(area);
      expect(geometry["type"], "Polygon");
      expect(geometry["coordinates"], [
        [
          [8.0, 50.0],
          [9.0, 50.0],
          [9.0, 51.0],
          [8.0, 50.0],
        ],
      ]);
    });

    test('converts several polygons into a MultiPolygon', () {
      final area = Area.areaFromJsonWithCAPData({
        "areaDesc": "Two rings",
        "polygon": [
          "50.0,8.0 50.0,9.0 51.0,9.0 50.0,8.0",
          "10.0,20.0 10.0,21.0 11.0,21.0 10.0,20.0",
        ],
      });

      final geometry = singleGeometry(area);
      expect(geometry["type"], "MultiPolygon");
      expect(geometry["coordinates"], [
        [
          [
            [8.0, 50.0],
            [9.0, 50.0],
            [9.0, 51.0],
            [8.0, 50.0],
          ],
        ],
        [
          [
            [20.0, 10.0],
            [21.0, 10.0],
            [21.0, 11.0],
            [20.0, 10.0],
          ],
        ],
      ]);
    });

    test('an area without a polygon yields an empty feature collection', () {
      final area = Area.areaFromJsonWithCAPData({"areaDesc": "No geometry"});

      expect(geoJsonOf(area)["features"], isEmpty);
    });

    test('converts a list of areas', () {
      final areas = Area.areaListFromJsonWithCAPData([
        {"areaDesc": "a", "polygon": "1.0,2.0 1.0,3.0 2.0,3.0 1.0,2.0"},
        {"areaDesc": "b", "polygon": "4.0,5.0 4.0,6.0 5.0,6.0 4.0,5.0"},
      ]);

      expect(areas.map((a) => a.description), ["a", "b"]);
      expect(singleGeometry(areas.first)["coordinates"], [
        [
          [2.0, 1.0],
          [3.0, 1.0],
          [3.0, 2.0],
          [2.0, 1.0],
        ],
      ]);
      expect(singleGeometry(areas.last)["coordinates"], [
        [
          [5.0, 4.0],
          [6.0, 4.0],
          [6.0, 5.0],
          [5.0, 4.0],
        ],
      ]);
    });

    test('keeps a geoJson that was already stored', () {
      // Cached alerts are read back through the same CAP code path, so an
      // already converted geometry must survive untouched.
      const stored = '{"type":"FeatureCollection","features":[]}';
      final areas = Area.areaListFromJsonWithCAPData([
        {"areaDesc": "a", "geoJson": stored},
      ]);

      expect(areas.single.geoJson, stored);
    });
  });

  group('Area json', () {
    test('round trips description and geometry', () {
      final area = Area(areaDesc: "a", geoJson: '{"features":[]}');
      final restored = Area.fromJson(
        jsonDecode(jsonEncode(area.toJson())) as Map<String, dynamic>,
      );

      expect(restored.description, "a");
      expect(restored.geoJson, '{"features":[]}');
    });

    test('a missing geoJson falls back to an empty string', () {
      expect(Area.fromJson({"areaDesc": "a"}).geoJson, "");
    });
  });
}
