import 'package:flutter/foundation.dart';
import 'package:foss_warn/services/allPlacesList.dart';
import 'package:foss_warn/services/apiHandler.dart';
import '../class/class_Place.dart';
import '../services/saveAndLoadSharedPreferences.dart';
import 'listHandler.dart';

class Update with ChangeNotifier {

  // delete preset
  Future<void> updateList(newPlaceName)  async {

    myPlaceList.add(Place(name: newPlaceName,
        geocode: geocodeMap[newPlaceName] ?? alertSwissPlacesMap[newPlaceName]!));
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
    print("Ort wurde entfernt");
    notifyListeners();
  }

  void updateView() {
    print("we have to rebuild the view");
    notifyListeners();
  }
}