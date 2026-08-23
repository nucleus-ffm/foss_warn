import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';

import 'package:foss_warn/class/class_bounding_box.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/widgets/dialogs/loading_screen.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/services/api_handler.dart';
import 'package:unifiedpush_platform_interface/data/push_endpoint.dart';
import 'package:uuid/uuid.dart';

import '../class/class_app_state.dart';
import '../class/class_unified_push_handler.dart';

/// register with the given boundingBox for push notifications
/// and add the new place to the myPlacesProvider list
///
/// returns a [String] with the confirmation id.
/// This ID can be used to check if the confirmation notification arrived
/// The confirmation is is an empty string if the subscription process was aborted
///
/// Throws [UnifiedPushRegistrationTimeoutError] if the registration failed
///
/// Throws [RegisterAreaError] if the registration request failed
///
/// Throws [SocketException] if the registration failed due to not working connection
Future<String> _subscribeForAreaWithPushNotifications({
  required BoundingBox boundingBox,
  required String selectedPlaceName,
  required BuildContext context,
  required WidgetRef ref,
  bool? currentLocation,
}) async {
  var localizations = context.localizations;
  LoadingScreen.instance().show(
    context: context,
    text: localizations.loading_screen_wait_for_push_to_complete,
  );

  // register listener
  final completer = Completer<void>();
  final sub = ref.listenManual(userPreferencesProvider, (_, next) {
    if (next.unifiedPushRegistered && !completer.isCompleted) {
      completer.complete();
    }
  });
  var userPreferences = ref.read(userPreferencesProvider);
  try {
    //@TODO(Nucleus): We need to handle the case of the push registration failing. We should abort the subscription process at this point
    try {
      await ref.read(unifiedPushHandlerProvider).setupUnifiedPush(context, ref);
    } on UnifiedPushRegistrationError {
      LoadingScreen.instance().showResult(
        text: localizations
            .add_my_place_with_map_loading_screen_subscription_error(
          "Failed to setup UnifiedPush",
        ),
      );
      rethrow;
    }

    // subscribe for new area and create new place
    // with the returned subscription id
    if (!context.mounted) return "";

    LoadingScreen.instance().show(
      context: context,
      text: localizations.loading_screen_wait_for_push_to_complete,
    );

    debugPrint(
      "wait for registration state=${userPreferences.unifiedPushRegistered}",
    );

    // wait for the registration to finish.
    // check if already done before we started listening
    if (ref.read(userPreferencesProvider).unifiedPushRegistered &&
        !completer.isCompleted) {
      completer.complete();
    }
    await completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        debugPrint(
          "Timeout waiting for unifiedPushRegistered to be set to true.",
        );
        throw UnifiedPushRegistrationTimeoutError();
      },
    );
  } finally {
    // make sure we close the completer even with the early returns
    sub.close();
  }

  var alertApi = ref.read(alertApiProvider);
  var uuid = const Uuid();

  // subscribe for new area and create new place
  // with the returned subscription id
  String subscriptionId = "";
  String confirmationId = "";
  try {
    SubscriptionApiResult result = await alertApi.registerArea(
      boundingBox: boundingBox,
      unifiedPushEndpoint: userPreferences.unifiedPushEndpoint,
    );
    subscriptionId = result.subscriptionId;
    confirmationId = result.confirmationId;
  } on RegisterAreaError catch (e) {
    debugPrint("Error: ${e.toString()}");
    ErrorLogger.writeLog(
      "subscription_handler.dart",
      "subscribe for area - RegisterAreaError",
      e.toString(),
    );
    if (!context.mounted) return "";
    LoadingScreen.instance().showResult(
      text:
          localizations.add_my_place_with_map_loading_screen_subscription_error(
        e.toString(),
      ),
    );
    rethrow;
  } on SocketException catch (e) {
    ErrorLogger.writeLog(
      "subscription_handler.dart",
      "subscribe for area - SocketException",
      e.toString(),
    );
    if (!context.mounted) return "";
    LoadingScreen.instance().showResult(
      text:
          localizations.add_my_place_with_map_loading_screen_subscription_error(
        e.toString(),
      ),
    );
    rethrow;
  }
  if (subscriptionId != "") {
    if (!context.mounted) return "";
    LoadingScreen.instance().show(
      context: context,
      text: localizations
          .add_my_place_with_map_loading_screen_subscription_success,
    );
    Place newPlace = Place(
      id: uuid.v4(),
      boundingBox: boundingBox,
      subscriptionId: subscriptionId,
      name: selectedPlaceName,
      isForCurrentLocation: currentLocation,
    );

    var places = ref.read(myPlacesProvider.notifier);

    places.add(newPlace);

    // cancel warning of missing places (ID: 3)
    NotificationService.cancelOneNotification(
      3,
    );
  }
  await Future.delayed(
    const Duration(seconds: 1),
  );
  LoadingScreen.instance().hide();
  return confirmationId;
}

/// register with the given boundingBox for push notifications
/// and add the new place to the myPlacesProvider list.
///
/// This method does not show any dialogs and can be used from the background
/// without a buildContext
///
/// returns a [String] with the confirmation id.
/// This ID can be used to check if the confirmation notification arrived
/// The confirmation is is an empty string if the subscription process was aborted
///
/// Throws [UnifiedPushRegistrationTimeoutError] if the registration failed
///
/// Throws [RegisterAreaError] if the registration request failed
///
/// Throws [SocketException] if the registration failed due to not working connection
Future<String> _subscribeForAreaWithPushNotificationsBackground({
  required BoundingBox boundingBox,
  required String selectedPlaceName,
  required Ref ref,
  bool? isForCurrentLocation,
}) async {
  var alertApi = ref.read(alertApiProvider);
  var uuid = const Uuid();

  // subscribe for new area and create new place
  // with the returned subscription id
  var userPreferences = ref.read(userPreferencesProvider);
  debugPrint(
    "wait for registration state=${userPreferences.unifiedPushRegistered}",
  );
  // wait for the registration to finish.
  if (!userPreferences.unifiedPushRegistered) {
    ErrorLogger.writeLog(
      "subscription_handler.dart",
      "subscribe for area in background - UnifiedPush not registered",
      "UnifiedPush not registered, can not continue in background",
    );
    return "";
  }

  // subscribe for new area and create new place
  // with the returned subscription id
  String subscriptionId = "";
  String confirmationId = "";
  try {
    SubscriptionApiResult result = await alertApi.registerArea(
      boundingBox: boundingBox,
      unifiedPushEndpoint: userPreferences.unifiedPushEndpoint,
    );
    subscriptionId = result.subscriptionId;
    confirmationId = result.confirmationId;
  } on RegisterAreaError catch (e) {
    debugPrint("Error: ${e.toString()}");
    ErrorLogger.writeLog(
      "subscription_handler.dart",
      "subscribe for area - RegisterAreaError",
      e.toString(),
    );
    rethrow;
  } on SocketException catch (e) {
    ErrorLogger.writeLog(
      "subscription_handler.dart",
      "subscribe for area - SocketException",
      e.toString(),
    );
    rethrow;
  }
  if (subscriptionId != "") {
    Place newPlace = Place(
      id: uuid.v4(),
      boundingBox: boundingBox,
      subscriptionId: subscriptionId,
      name: selectedPlaceName,
      isForCurrentLocation: isForCurrentLocation,
    );

    var places = ref.read(myPlacesProvider.notifier);

    places.add(newPlace);

    // cancel warning of missing places (ID: 3)
    NotificationService.cancelOneNotification(
      3,
    );
  }
  return confirmationId;
}

/// Add a new place with the selected bounding box but without registering for
/// push notifications.
Future<Null> _subscribeForAreaNoPush({
  required BoundingBox boundingBox,
  required String selectedPlaceName,
  required WidgetRef ref,
}) async {
  var uuid = const Uuid();
  Place newPlace = Place(
    id: uuid.v4(),
    boundingBox: boundingBox,
    name: selectedPlaceName,
  );

  var places = ref.read(myPlacesProvider.notifier);

  places.add(newPlace);
}

/// Add a new place with the selected bounding box but without registering for
/// push notifications.
Future<Null> _subscribeForAreaNoPushBackground({
  required BoundingBox boundingBox,
  required String selectedPlaceName,
  required Ref ref,
  required bool isForCurrentLocation,
}) async {
  var uuid = const Uuid();
  Place newPlace = Place(
    id: uuid.v4(),
    boundingBox: boundingBox,
    name: selectedPlaceName,
    isForCurrentLocation: isForCurrentLocation,
  );

  var places = ref.read(myPlacesProvider.notifier);

  await places.add(newPlace);
}

/// Register for push notification or if [noPushNotification] is set to true
/// just adds a new place with the selected bounding box
/// can throw exceptions if subscribing failed
Future<String?> subscribeForArea({
  required BoundingBox boundingBox,
  required String selectedPlaceName,
  required BuildContext context,
  required WidgetRef ref,
  noPushNotification = false,
  isForCurrentLocation = false,
}) async {
  switch (noPushNotification) {
    case true:
      return await _subscribeForAreaNoPush(
        boundingBox: boundingBox,
        selectedPlaceName: selectedPlaceName,
        ref: ref,
      );
    case false:
      return await _subscribeForAreaWithPushNotifications(
        boundingBox: boundingBox,
        selectedPlaceName: selectedPlaceName,
        context: context,
        ref: ref,
        currentLocation: isForCurrentLocation,
      );
  }
  return null;
}

/// Register for push notification or is [noPushNotification] is set to true
/// just adds a new place with the selected bounding box
Future<String?> subscribeForAreaInBackground({
  required BoundingBox boundingBox,
  required String selectedPlaceName,
  required Ref ref,
  noPushNotification = false,
  isForCurrentLocation = false,
}) async {
  switch (noPushNotification) {
    case true:
      return _subscribeForAreaNoPushBackground(
        boundingBox: boundingBox,
        selectedPlaceName: selectedPlaceName,
        ref: ref,
        isForCurrentLocation: isForCurrentLocation,
      );
    case false:
      return _subscribeForAreaWithPushNotificationsBackground(
        boundingBox: boundingBox,
        selectedPlaceName: selectedPlaceName,
        ref: ref,
        isForCurrentLocation: isForCurrentLocation,
      );
  }
  return null;
}

/// resubscribed for all stored areas with the current push notification setup
/// this methode can be called after the push notification config has changed,
/// to update the subscription on the serverside
Future<void> resubscribeForAllArea(BuildContext context, WidgetRef ref) async {
  var alertApi = ref.read(alertApiProvider);
  var places = ref.read(myPlacesProvider);
  var userPreferences = ref.read(userPreferencesProvider);
  var appStateService = ref.read(appStateProvider.notifier);
  appStateService.setReSubscriptionInProgress(true);
  debugPrint("[resubscribeForAllArea] Resubscribing...");

  LoadingScreen.instance().show(
    context: context,
    text: "Resubscribing for all of your areas. Please wait.",
  );
  String? failure;
  try {
    for (Place place in places) {
      String newSubscriptionId = "";
      // register again
      if (place.subscriptionId == null) {
        continue;
      }
      try {
        // remove old subscription, if the subscription is already deleted nothing changes
        await alertApi.unregisterArea(subscriptionId: place.subscriptionId!);

        SubscriptionApiResult result = await alertApi.registerArea(
          boundingBox: place.boundingBox,
          unifiedPushEndpoint: userPreferences.unifiedPushEndpoint,
        );
        newSubscriptionId = result.subscriptionId;

        // replace the old subscription id with the new one
        await ref.read(myPlacesProvider.notifier).set(
              ref.read(myPlacesProvider).updateEntry(
                    place.copyWith(
                      subscriptionId: newSubscriptionId,
                    ),
                  ),
            );
      } on RegisterAreaError catch (e) {
        if (!context.mounted) return;
        failure = "Failed to register for area. The server responded with $e";
        await ref.read(myPlacesProvider.notifier).set(
              ref.read(myPlacesProvider).updateEntry(
                    place.copyWith(
                      isExpired: true,
                    ),
                  ),
            );
      } on UnregisterAreaError catch (e) {
        if (!context.mounted) return;
        failure = "Failed to unregister for area. The server responded with $e";
        await ref.read(myPlacesProvider.notifier).set(
              ref.read(myPlacesProvider).updateEntry(
                    place.copyWith(
                      isExpired: true,
                    ),
                  ),
            );
      }
    }
  } finally {
    appStateService.setReSubscriptionInProgress(false);
    if (failure == null) {
      LoadingScreen.instance().hide();
    } else {
      LoadingScreen.instance().showResult(text: failure);
    }
  }
}

/// Resubscribe for a place in case of expired subscription
/// takes a WidgetRef as parameter, the rest is
/// the same as `resubscribeForOneAreaInBackgroundFromBackground`
Future<void> resubscribeForOneAreaInBackground(
  WidgetRef ref,
  Place place,
) async {
  var alertApi = ref.read(alertApiProvider);
  String newSubscriptionId = "";
  var userPreferences = ref.read(userPreferencesProvider);

  try {
    SubscriptionApiResult result = await alertApi.registerArea(
      boundingBox: place.boundingBox,
      unifiedPushEndpoint: userPreferences.unifiedPushEndpoint,
    );
    newSubscriptionId = result.subscriptionId;
    await ErrorLogger.writeLog(
      "subscription_handler.dart",
      "Info message",
      "Resubscribe for ${place.name} - subscription ID changed from ${place.subscriptionId} to $newSubscriptionId",
    );
    ref.read(myPlacesProvider.notifier).set(
          ref.read(myPlacesProvider).updateEntry(
                place.copyWith(
                  subscriptionId: newSubscriptionId,
                  isExpired: false,
                ),
              ),
        );
  } on RegisterAreaError catch (e) {
    debugPrint("RegisterAreaError $e");
    await ErrorLogger.writeLog(
      "subscription_handler.dart",
      "resubscribeForOneAreaInBackground",
      e.toString(),
    );
  }
}

/// Resubscribe for a place in case of expired subscription
/// takes a ProviderContainer instead of a WidgetRef,
/// the rest is the same as `resubscribeForOneAreaInBackground`
Future<void> resubscribeForOneAreaInBackgroundFromBackground(
  ProviderContainer ref,
  Place place,
) async {
  var alertApi = ref.read(alertApiProvider);
  String newSubscriptionId = "";
  var userPreferences = ref.read(userPreferencesProvider);

  try {
    SubscriptionApiResult result = await alertApi.registerArea(
      boundingBox: place.boundingBox,
      unifiedPushEndpoint: userPreferences.unifiedPushEndpoint,
    );
    newSubscriptionId = result.subscriptionId;
    await ErrorLogger.writeLog(
      "subscription_handler.dart",
      "Info message",
      "Resubscribe for ${place.name} - subscription ID changed from ${place.subscriptionId} to $newSubscriptionId",
    );
    await ref.read(myPlacesProvider.notifier).set(
          ref.read(myPlacesProvider).updateEntry(
                place.copyWith(
                  subscriptionId: newSubscriptionId,
                  isExpired: false,
                ),
              ),
        );
  } on RegisterAreaError catch (e) {
    debugPrint("RegisterAreaError $e");
    await ErrorLogger.writeLog(
      "subscription_handler.dart",
      "resubscribeForOneAreaInBackground",
      e.toString(),
    );
  }
}

/// Send an update message to the server to keep the subscriptions alive
///
/// This method needs to be called at least once a week to ensure that
/// the subscription on the server hasn't been removed.
/// Calling it more often is also fine.
Future<void> updateAllSubscriptions(WidgetRef ref) async {
  debugPrint("UpdateAllSubscriptions");
  var places = await ref.read(cachedPlacesProvider.future);
  var api = ref.read(alertApiProvider);
  for (Place place in places) {
    if (place.subscriptionId == null) continue;
    try {
      debugPrint("Send update for subscription");
      await api.updateSubscription(subscriptionId: place.subscriptionId!);
    } on InvalidSubscriptionError {
      // the subscription expired, we have to register again
      resubscribeForOneAreaInBackground(ref, place);
    } on RegisterAreaError catch (e) {
      debugPrint("Failed to update all subscriptions due to $e");
      ErrorLogger.writeLog(
        "subscription_handler.dart",
        "updateAllSubscriptions",
        e.toString(),
      );
    } on PlaceSubscriptionError catch (e) {
      debugPrint("Failed to update all subscriptions due to $e");
      ErrorLogger.writeLog(
        "subscription_handler.dart",
        "updateAllSubscriptions",
        e.toString(),
      );
    }
  }
}

/// Similar to [updateAllSubscriptions] but with using a ProviderContainer to
/// be able to call this from background.
Future<void> updateAllSubscriptionsFromBackground(ProviderContainer ref) async {
  debugPrint("UpdateAllSubscriptionFromBackground");

  var places = await ref.read(cachedPlacesProvider.future);
  var api = ref.read(alertApiProvider);
  for (Place place in places) {
    if (place.subscriptionId == null) continue;
    try {
      debugPrint("Send update for subscription");
      await api.updateSubscription(subscriptionId: place.subscriptionId!);
    } on InvalidSubscriptionError {
      // the subscription expired, we have to register again
      await resubscribeForOneAreaInBackgroundFromBackground(ref, place);
    } on RegisterAreaError catch (e) {
      debugPrint("Failed to update all subscriptions due to $e");
      ErrorLogger.writeLog(
        "subscription_handler.dart",
        "updateAllSubscriptions",
        e.toString(),
      );
    }
  }
}

/// Update the subscription with an updated push notification endpoint
/// This requires the latest version of the server.
Future<void> updatePushNotificationConfigForSubscription(
  PushEndpoint endpoint,
  WidgetRef ref,
) async {
  var subscriptions = ref.read(myPlacesProvider);
  var alertAPI = ref.read(alertApiProvider);
  for (Place place in subscriptions) {
    try {
      // only update the push notification config, if it is a push notification
      // subscription and the pubkey is not null.
      // If the key is null, it is not an encrypted setup which we will
      // deprecate in the future.
      if (place.subscriptionId != null && endpoint.pubKeySet != null) {
        await alertAPI.updateSubscriptionPushNotificationConfig(
          subscriptionId: place.subscriptionId!,
          token: endpoint.url,
          webPushPublicKey: endpoint.pubKeySet!.pubKey,
          webPushAuthKey: endpoint.pubKeySet!.auth,
        );
      }
    } on RegisterAreaError {
      debugPrint("Failed to update subscription");
    }
  }
}

/// Remove the subscription for the given place
Future<void> removeSubscription(
  Place place,
  WidgetRef ref,
  BuildContext context,
) async {
  var alertApi = ref.read(alertApiProvider);
  var localizations = context.localizations;
  var theme = Theme.of(context);
  var scaffoldMessenger = ScaffoldMessenger.of(context);

  // Unsubscribe from server
  debugPrint("unregister from server for place ${place.name}");
  if (place.subscriptionId == null) {
    await ref.read(myPlacesProvider.notifier).remove(place);
  } else {
    var appSate = ref.read(appStateProvider.notifier);

    // only unsubscribe from server if the subscriptions isn't a local subscription
    if (place.subscriptionId != null) {
      try {
        appSate.setReSubscriptionInProgress(true);
        await alertApi.unregisterArea(
          subscriptionId: place.subscriptionId!,
        );
        await ref.read(myPlacesProvider.notifier).remove(place);
      } on UnregisterAreaError {
        // we currently can not unsubscribe - show a snack bar to inform the
        // user to check their internet connection
        final snackBar = SnackBar(
          content: Text(
            localizations.delete_place_error,
            style: TextStyle(color: theme.colorScheme.onErrorContainer),
          ),
          backgroundColor: theme.colorScheme.errorContainer,
        );
        scaffoldMessenger.showSnackBar(snackBar);
      } finally {
        appSate.setReSubscriptionInProgress(false);
      }
    } else {
      await ref.read(myPlacesProvider.notifier).remove(place);
    }
  }
}

/// Remove and unsubscribe for all stored places
Future<void> removeAllPlaces(WidgetRef ref, BuildContext context) async {
  var places = ref.read(myPlacesProvider);
  for (Place place in places) {
    await removeSubscription(place, ref, context);
  }
}
