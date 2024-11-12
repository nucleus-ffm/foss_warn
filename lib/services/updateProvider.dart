import 'package:flutter/foundation.dart';
import 'package:foss_warn/services/apiHandler.dart';
import '../class/abstract_Place.dart';
import '../services/saveAndLoadSharedPreferences.dart';
import 'listHandler.dart';

class Update with ChangeNotifier {
  // delete preset
  Future<void> updateList(Place newPlace) async {
    print("add new place: ${newPlace.name}");
    myPlaceList.add(newPlace);
    saveMyPlacesList();
    await callAPI();
    print("we have to rebuild the view");
    notifyListeners();
  }

  void updateReadStatusInList() {
    print("we have to rebuild the view");
    notifyListeners();
  }

  /// remove the given place from the List,
  /// save the updated list and update the view
  void deletePlace(place) {
    myPlaceList.remove(place);
    saveMyPlacesList();
    print("place removed");
    notifyListeners();
  }

  /// notifies the listeners to rebuild the view
  void updateView() {
    print("we have to rebuild the view");
    notifyListeners();
  }
}
