import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/services/api_handler.dart';
import '../class/abstract_place.dart';
import 'save_and_load_shared_preferences.dart';
import 'list_handler.dart';

final updaterProvider = Provider((ref) => Update());

class Update with ChangeNotifier {
  // delete preset
  Future<void> updateList(Place newPlace) async {
    debugPrint("add new place: ${newPlace.name}");
    myPlaceList.add(newPlace);
    saveMyPlacesList();
    await callAPI();
    debugPrint("we have to rebuild the view");
    notifyListeners();
  }

  void updateReadStatusInList() {
    debugPrint("we have to rebuild the view");
    notifyListeners();
  }

  /// remove the given place from the List,
  /// save the updated list and update the view
  void deletePlace(place) {
    myPlaceList.remove(place);
    saveMyPlacesList();
    debugPrint("place removed");
    notifyListeners();
  }

  /// notifies the listeners to rebuild the view
  void updateView() {
    debugPrint("we have to rebuild the view");
    notifyListeners();
  }
}
