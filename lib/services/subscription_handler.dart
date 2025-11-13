import 'dart:io';

import 'package:flutter/cupertino.dart';
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
Future<String> subscribeForArea({
  required BoundingBox boundingBox,
  required String selectedPlaceName,
  required BuildContext context,
  required WidgetRef ref,
}) async {
  //@TODO(Nucleus): We need to handle the case of the push registration failing. We should abort the subscription process at this point
  await ref.watch(unifiedPushHandlerProvider).setupUnifiedPush(context, ref);
  if (!context.mounted) return "";
  var localizations = context.localizations;
  var alertApi = ref.read(alertApiProvider);
  var uuid = const Uuid();

  // subscribe for new area and create new place
  // with the returned subscription id
  if (!context.mounted) return "";
  LoadingScreen.instance().show(
    context: context,
    text: localizations.loading_screen_loading,
  );

  LoadingScreen.instance().show(
    context: context,
    text: localizations.loading_screen_wait_for_push_to_complete,
  );

  var userPreferences = ref.read(userPreferencesProvider);
  debugPrint(
    "wait for registration state=${userPreferences.unifiedPushRegistered}",
  );
  // wait for the registration to finish.
  if (!userPreferences.unifiedPushRegistered) {
    await Future.doWhile(() async {
      await Future.delayed(const Duration(microseconds: 1));
      userPreferences = ref.read(userPreferencesProvider);
      return !userPreferences.unifiedPushRegistered;
    }).timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        debugPrint(
          "Timeout waiting for unifiedPushRegistered to be set to true.",
        );
        throw UnifiedPushRegistrationTimeoutError();
      },
    );
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
    ErrorLogger.writeErrorLog(
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
    ErrorLogger.writeErrorLog(
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

/// resubscribed for all stored areas with the current push notification setup
/// this methode can be called after the push notification config has changed,
/// to update the subscription on the serverside
Future<void> resubscribeForAllArea(BuildContext context, WidgetRef ref) async {
  var alertApi = ref.read(alertApiProvider);
  var places = ref.read(myPlacesProvider);
  var userPreferences = ref.read(userPreferencesProvider);
  var appStateSevice = ref.read(appStateProvider.notifier);
  appStateSevice.setReSubscriptionInProgress(true);
  debugPrint("[resubscribeForAllArea] Resubscribing...");

  LoadingScreen.instance().show(
    context: context,
    text: "Resubscribing for all of your areas. Please wait.",
  );

  for (Place place in places) {
    String newSubscriptionId = "";
    // register again
    try {
      // remove old subscription, if the subscription is already deleted nothing changes
      await alertApi.unregisterArea(subscriptionId: place.subscriptionId);

      SubscriptionApiResult result = await alertApi.registerArea(
        boundingBox: place.boundingBox,
        unifiedPushEndpoint: userPreferences.unifiedPushEndpoint,
      );
      newSubscriptionId = result.subscriptionId;
    } on RegisterAreaError catch (e) {
      if (!context.mounted) return;
      LoadingScreen.instance().show(
        context: context,
        text: "Failed to register for area. The server responded with $e",
      );
      LoadingScreen.instance().hide();
      return;
    } on UnregisterAreaError catch (e) {
      if (!context.mounted) return;
      LoadingScreen.instance().show(
        context: context,
        text: "Failed to unregister for area. The server responded with $e",
      );
      LoadingScreen.instance().hide();
      return;
    }

    // replace the old subscription id with the new one
    ref.read(myPlacesProvider.notifier).set(
          ref.read(myPlacesProvider).updateEntry(
                place.copyWith(
                  subscriptionId: newSubscriptionId,
                ),
              ),
        );
  }
  appStateSevice.setReSubscriptionInProgress(false);
  LoadingScreen.instance().hide();
}

/// Resubscribe for a place in case of expired subscription
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
  } on RegisterAreaError catch (e) {
    debugPrint("RegisterAreaError $e");
    ErrorLogger.writeErrorLog(
      "subscription_handler.dart",
      "resubscribeForOneAreaInBackground",
      e.toString(),
    );
  }

  ref.read(myPlacesProvider.notifier).set(
        ref.read(myPlacesProvider).updateEntry(
              place.copyWith(
                subscriptionId: newSubscriptionId,
                isExpired: false,
              ),
            ),
      );
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
    try {
      debugPrint("Send update for subscription");
      await api.updateSubscription(subscriptionId: place.subscriptionId);
    } on InvalidSubscriptionError {
      // the subscription expired, we have to register again
      resubscribeForOneAreaInBackground(ref, place);
    } on RegisterAreaError catch (e) {
      debugPrint("Failed to update all subscriptions due to $e");
      ErrorLogger.writeErrorLog(
        "subscription_handler.dart",
        "updateAllSubscriptions",
        e.toString(),
      );
    }
  }
}
