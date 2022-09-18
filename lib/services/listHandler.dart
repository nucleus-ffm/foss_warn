import '../class/class_Place.dart';
import '../class/class_WarnMessage.dart';

List<Place> myPlaceList = [];
List<String> readWarnings = [];
List<String> alreadyNotifiedWarnings = [];
List<String> notificationSettingsImportance = [];
List<WarnMessage> warnMessageList = []; // where the warnigs for my places are stored
List<WarnMessage> allWarnMessageList = []; // used if showAllWarnings is enabled to store all warnings
Map<String, String> geocodeMap = new Map();
List<String> allAvailablePlacesNames = [];