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
      unifiedPushRegistered: false,
    ),
  );
});

class AppStateService extends StateNotifier<AppState> {
  AppStateService(
    super.state,
  );

  // StateNotifier notifies whenever a new state object is assigned, even when
  // it carries the same values. The flags below are written on every polling
  // cycle, so only assign a new state when the value actually changed.

  void setError(bool value) {
    if (state.error == value) return;
    state = state.copyWith(error: value);
  }

  void setAreWarningsFromCache(bool value) {
    if (state.areWarningsFromCache == value) return;
    state = state.copyWith(areWarningsFromCache: value);
  }

  void setIsFirstFetch(bool value) {
    if (state.isFirstFetch == value) return;
    state = state.copyWith(isFirstFetch: value);
  }

  void setPushNotificationSetupError(bool value) {
    if (state.pushNotificationSetupError == value) return;
    state = state.copyWith(pushNotificationSetupError: value);
  }

  void setReSubscriptionInProgress(bool value) {
    if (state.reSubscriptionInProgress == value) return;
    state = state.copyWith(reSubscriptionInProgress: value);
  }

  void setUnifiedPushRegistered(bool value) {
    if (state.unifiedPushRegistered == value) return;
    state = state.copyWith(unifiedPushRegistered: value);
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

  /// flag to prevent multiple UnifiedPush registrations resulting in
  /// duplicated callback calls
  final bool unifiedPushRegistered;

  AppState({
    required this.error,
    required this.areWarningsFromCache,
    required this.isFirstFetch,
    required this.pushNotificationSetupError,
    required this.reSubscriptionInProgress,
    required this.unifiedPushRegistered,
  });

  AppState copyWith({
    bool? error,
    bool? areWarningsFromCache,
    bool? isFirstFetch,
    bool? pushNotificationSetupError,
    bool? reSubscriptionInProgress,
    bool? unifiedPushRegistered,
  }) =>
      AppState(
        error: error ?? this.error,
        areWarningsFromCache: areWarningsFromCache ?? this.areWarningsFromCache,
        isFirstFetch: isFirstFetch ?? this.isFirstFetch,
        pushNotificationSetupError:
            pushNotificationSetupError ?? this.pushNotificationSetupError,
        reSubscriptionInProgress:
            reSubscriptionInProgress ?? this.reSubscriptionInProgress,
        unifiedPushRegistered:
            unifiedPushRegistered ?? this.unifiedPushRegistered,
      );
}
