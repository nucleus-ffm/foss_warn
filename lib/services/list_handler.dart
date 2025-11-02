import 'dart:convert';

import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../class/class_warn_message.dart';

final cachedPlacesProvider = FutureProvider<List<Place>>((ref) async {
  SharedPreferencesWithCache preferences =
      await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );

  if (preferences.containsKey("MyPlacesListAsJson")) {
    List<dynamic> data =
        jsonDecode(preferences.getString("MyPlacesListAsJson")!);

    List<Place> newPlaces = [];
    for (int i = 0; i < data.length; i++) {
      newPlaces.add(Place.fromJson(data[i]));
    }

    return newPlaces;
  }

  return [];
});

final myPlacesProvider = StateNotifierProvider<MyPlacesService, List<Place>>(
  (ref) {
    var placesSnapshot = ref.watch(cachedPlacesProvider);
    return MyPlacesService(
      placesSnapshot.when(
        data: (data) => data,
        error: (error, stackTrace) => [],
        loading: () => [],
      ),
    );
  },
);

class MyPlacesService extends StateNotifier<List<Place>> {
  MyPlacesService(super.state);

  Future<void> add(Place place) async {
    var places = List<Place>.from(state); // We need a copy
    places.add(place);

    await set(places);
  }

  Future<void> set(List<Place> places) async {
    SharedPreferencesWithCache preferences =
        await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );

    preferences.setString("MyPlacesListAsJson", jsonEncode(places));

    state = places;
  }

  Future<void> remove(Place place) async {
    var places = List<Place>.from(state);
    places.remove(place);

    await set(places);
  }

  List<Place> get places => state;
}

extension UpdateListEntry<T> on List<T> {
  /// Update a single element in a list
  /// [element] the element to update. Must be uniquely identifiable through the == operator
  List<T> updateEntry(T element) {
    int index = indexOf(element);

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
