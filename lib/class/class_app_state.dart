class AppState {
  bool error = false; // true if API call and parsing was not successful
  bool areWarningsFromCache = false;
  bool isFirstFetch =
      true; // used to display a text that the app is fetching new alerts if the app is freshly started
}
