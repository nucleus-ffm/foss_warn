import '../enums/data_fetch_status.dart';

class AppState {
  bool error = false; // true if API call and parsing was not successful
  bool areWarningsFromCache = false;
}
