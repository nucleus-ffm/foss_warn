import '../class/class_fpas_place.dart';

extension ListFilterWithNull<T> on List<T> {
  /// return the first element for which the test was successful,
  /// or return null if no element matches the test
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension ListHasExpiredPlaces on List<Place> {
  /// returns true if any place in the list is expired, false if no place is expired
  bool get hasExpiredPlaces {
    return any((Place place) => place.isExpired);
  }
}
