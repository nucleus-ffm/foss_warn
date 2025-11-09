class AppState {
  /// Flag that indicates that there was an error
  bool error = false;

  /// Flag to indicate that the displayed alerts are just from the cache and could
  /// be out-dated. This should only happen, if the user does not have an internet connection
  bool areWarningsFromCache = false;

  /// used to display a text that the app is fetching new alerts if the app is freshly started
  bool isFirstFetch = true;

  /// Flag to indicate an error with the push notification setup
  bool pushNotificationSetupError = false;

  /// Flag that is set to true when we are resubscribing places.
  /// This is to avoid race conditions with the update loop, which could mark the
  /// place as expired if it tries to fetch alerts just between we unsubscribed
  /// the old subscriptions and not yet have resubscribed.
  bool reSubscriptionInProgress = false;
}
