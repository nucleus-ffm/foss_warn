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
    print("müsste jetzt neubauen");
    notifyListeners();
  }

  void updateReadStatusInList() {
    print("müsste jetzt neubauen");
    notifyListeners();
  }

  void deletePlace(place) {
    myPlaceList.remove(place);
    saveMyPlacesList();
    print("Ort wurde entfernt");
    notifyListeners();
  }

  void updateView() {
    print("müsste jetzt neubauen");
    notifyListeners();
  }
}