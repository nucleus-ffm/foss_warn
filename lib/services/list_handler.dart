import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../class/class_warn_message.dart';

final myPlacesProvider = StateNotifierProvider<MyPlacesService, List<Place>>(
  (ref) => MyPlacesService([]),
);

class MyPlacesService extends StateNotifier<List<Place>> {
  MyPlacesService(super.state);

  void add(Place place) {
    var newPlaces = List<Place>.from(state); // We need a copy
    newPlaces.add(place);
    state = newPlaces;
  }

  set places(List<Place> places) => state = places;

  void remove(Place place) {
    var newPlaces = List<Place>.from(state);
    newPlaces.remove(place);
    state = newPlaces;
  }

  void clear() {
    state = [];
  }

  List<Place> get places => state;
}

extension UpdateListEntry<T> on List<T> {
  /// Update a single element in a list
  /// [element] the element to update. Must be uniquely identifiable through the == operator
  List<T> updateEntry(T element) {
    var index = indexOf(element);

    return [
      ...sublist(0, index),
      element,
      ...sublist(index + 1),
    ];
  }
}

List<String> notificationSettingsImportance = [];
// used if showAllWarnings is enabled to store all warnings
List<WarnMessage> mapWarningsList = [];
List<Place> allAvailablePlacesNames = [];
