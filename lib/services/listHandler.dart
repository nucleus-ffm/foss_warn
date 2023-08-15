import '../class/class_WarnMessage.dart';
import '../class/abstract_Place.dart';

List<Place> myPlaceList = [];
List<String> notificationSettingsImportance = [];
// where the warnings for my places are stored
List<WarnMessage> warnMessageList = [];
// used if showAllWarnings is enabled to store all warnings
List<WarnMessage> allWarnMessageList = [];
Map<String, String> geocodeMap = new Map();
List<Place> allAvailablePlacesNames = [];
