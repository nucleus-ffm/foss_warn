import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/class/class_bounding_box.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/extensions/list.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:latlong2/latlong.dart';

Place buildPlace(String id, {bool isExpired = false}) => Place(
      id: id,
      name: "Place $id",
      isExpired: isExpired,
      boundingBox: BoundingBox(
        minLatLng: const LatLng(1, 2),
        maxLatLng: const LatLng(3, 4),
      ),
    );

void main() {
  group('updateEntry', () {
    test('returns a new list and leaves the receiver untouched', () {
      // updateEntry is pure. Call sites that ignore the return value silently
      // drop the update, which is how the alert update flags got lost.
      final original = [buildPlace("a"), buildPlace("b")];

      final updated = original.updateEntry(buildPlace("b", isExpired: true));

      expect(identical(updated, original), isFalse);
      expect(original[1].isExpired, isFalse, reason: "receiver was mutated");
      expect(updated[1].isExpired, isTrue);
    });

    test('replaces the matching element in place and keeps the order', () {
      final original = [buildPlace("a"), buildPlace("b"), buildPlace("c")];

      final updated = original.updateEntry(buildPlace("b", isExpired: true));

      expect(updated.map((p) => p.id), ["a", "b", "c"]);
      expect(updated[0].isExpired, isFalse);
      expect(updated[1].isExpired, isTrue);
      expect(updated[2].isExpired, isFalse);
    });

    test('appends the element when it is not in the list', () {
      final original = [buildPlace("a")];

      final updated = original.updateEntry(buildPlace("b"));

      expect(updated.map((p) => p.id), ["a", "b"]);
    });

    test('works on an empty list', () {
      expect(<Place>[].updateEntry(buildPlace("a")).single.id, "a");
    });
  });

  group('firstWhereOrNull', () {
    test('returns the first match', () {
      final places = [buildPlace("a"), buildPlace("b"), buildPlace("c")];

      expect(places.firstWhereOrNull((p) => p.id == "b")?.id, "b");
    });

    test('returns null instead of throwing when nothing matches', () {
      expect(
        [buildPlace("a")].firstWhereOrNull((p) => p.id == "zzz"),
        isNull,
      );
    });
  });

  group('hasExpiredPlaces', () {
    test('is false for an empty list and for healthy places', () {
      expect(<Place>[].hasExpiredPlaces, isFalse);
      expect([buildPlace("a"), buildPlace("b")].hasExpiredPlaces, isFalse);
    });

    test('is true as soon as one place is expired', () {
      expect(
        [buildPlace("a"), buildPlace("b", isExpired: true)].hasExpiredPlaces,
        isTrue,
      );
    });
  });
}
