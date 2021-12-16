import 'package:flutter/foundation.dart';
import '../class/class_Place.dart';
import '../services/saveAndLoadSharedPreferences.dart';
import 'listHandler.dart';

class Update with ChangeNotifier {

  // delete preset
  void updateList(newPlaceName) {
    myPlaceList.add(Place(name: newPlaceName));
    saveMyPlacesList();
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