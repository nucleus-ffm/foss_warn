import 'package:flutter/foundation.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/services/api_handler.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/warnings.dart';

final updaterProvider = Provider(
  (ref) => Update(
    myPlacesService: ref.watch(myPlacesProvider.notifier),
  ),
);

class Update with ChangeNotifier {
  MyPlacesService myPlacesService;

  Update({required this.myPlacesService});

  // delete preset
  Future<void> updateList({
    required AlertAPI alertApi,
    required WarningService warningService,
    required Place newPlace,
  }) async {
    debugPrint("add new place: ${newPlace.name}");

    myPlacesService.add(newPlace);

    await callAPI(
      alertApi: alertApi,
      warningService: warningService,
      places: myPlacesService.places,
    );
    debugPrint("we have to rebuild the view");
    notifyListeners();
  }

  void updateReadStatusInList() {
    debugPrint("we have to rebuild the view");
    notifyListeners();
  }

  /// remove the given place from the List,
  /// save the updated list and update the view
  Future<void> deletePlace(place) async {
    await myPlacesService.remove(place);
    notifyListeners();
  }

  /// notifies the listeners to rebuild the view
  void updateView() {
    debugPrint("we have to rebuild the view");
    notifyListeners();
  }
}
