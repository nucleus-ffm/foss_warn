import '../class/class_WarnMessage.dart';
import '../class/abstract_Place.dart';

List<Place> myPlaceList = [];
List<String> notificationSettingsImportance = [];
List<WarnMessage> warnMessageList = []; // where the warnings for my places are stored
List<WarnMessage> allWarnMessageList = []; // used if showAllWarnings is enabled to store all warnings
Map<String, String> geocodeMap = new Map();
List<Place> allAvailablePlacesNames = [];