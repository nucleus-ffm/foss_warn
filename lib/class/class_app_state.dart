class AppState {
  bool error = false; // true if API call and parsing was not successful
  bool areWarningsFromCache = false;
  bool isFirstFetch =
      true; // used to display a text that the app is fetching new alerts if the app is freshly started
  bool pushNotificationSetupError = false;

  /// Flag that is set to true when we are resubscribing places.
  /// This is to avoid race conditions with the update loop, which could mark the
  /// place as expired if it tries to fetch alerts just between we unsubscribed
  /// the old subscriptions and not yet have resubscribed.
  bool reSubscriptionInProgress = false;
}
