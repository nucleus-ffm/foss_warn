import 'package:flutter_riverpod/flutter_riverpod.dart';

final appStateProvider =
    StateNotifierProvider<AppStateService, AppState>((ref) {
  return AppStateService(
    AppState(
      error: false,
      isFirstFetch: false,
      areWarningsFromCache: false,
      reSubscriptionInProgress: false,
      pushNotificationSetupError: false,
    ),
  );
});

class AppStateService extends StateNotifier<AppState> {
  AppStateService(
    super.state,
  );

  void setError(bool value) {
    state = state.copyWith(error: value);
  }

  void setAreWarningsFromCache(bool value) {
    state = state.copyWith(areWarningsFromCache: value);
  }

  void setIsFirstFetch(bool value) {
    state = state.copyWith(isFirstFetch: value);
  }

  void setPushNotificationSetupError(bool value) {
    state = state.copyWith(pushNotificationSetupError: value);
  }

  void setReSubscriptionInProgress(bool value) {
    state = state.copyWith(reSubscriptionInProgress: value);
  }
}

class AppState {
  /// Flag that indicates that there was an error
  final bool error;

  /// Flag to indicate that the displayed alerts are just from the cache and could
  /// be out-dated. This should only happen, if the user does not have an internet connection
  final bool areWarningsFromCache;

  /// used to display a text that the app is fetching new alerts if the app is freshly started
  final bool isFirstFetch;

  /// Flag to indicate an error with the push notification setup
  final bool pushNotificationSetupError;

  /// Flag that is set to true when we are resubscribing places.
  /// This is to avoid race conditions with the update loop, which could mark the
  /// place as expired if it tries to fetch alerts just between we unsubscribed
  /// the old subscriptions and not yet have resubscribed.
  final bool reSubscriptionInProgress;

  AppState({
    required this.error,
    required this.areWarningsFromCache,
    required this.isFirstFetch,
    required this.pushNotificationSetupError,
    required this.reSubscriptionInProgress,
  });

  AppState copyWith({
    bool? error,
    bool? areWarningsFromCache,
    bool? isFirstFetch,
    bool? pushNotificationSetupError,
    bool? reSubscriptionInProgress,
  }) =>
      AppState(
        error: error ?? this.error,
        areWarningsFromCache: areWarningsFromCache ?? this.areWarningsFromCache,
        isFirstFetch: isFirstFetch ?? this.isFirstFetch,
        pushNotificationSetupError:
            pushNotificationSetupError ?? this.pushNotificationSetupError,
        reSubscriptionInProgress:
            reSubscriptionInProgress ?? this.reSubscriptionInProgress,
      );
}
