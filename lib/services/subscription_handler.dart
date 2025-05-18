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

/// register with the given boundingBox for push notifications
/// and add the new place to the myPlacesProvider list
Future<void> subscribeForArea({
  required BoundingBox boundingBox,
  required String selectedPlaceName,
  required BuildContext context,
  required WidgetRef ref,
}) async {
  var userPreferences = ref.watch(userPreferencesProvider);
  var localizations = context.localizations;
  var alertApi = ref.read(alertApiProvider);
  var uuid = const Uuid();

  // subscribe for new area and create new place
  // with the returned subscription id
  if (!context.mounted) return;
  LoadingScreen.instance().show(
    context: context,
    text: localizations.loading_screen_loading,
  );
  String subscriptionId = "";
  try {
    subscriptionId = await alertApi.registerArea(
      boundingBox: boundingBox,
      unifiedPushEndpoint: userPreferences.unifiedPushEndpoint,
    );
  } on RegisterAreaError catch (e) {
    debugPrint("Error: ${e.toString()}");
    ErrorLogger.writeErrorLog(
      "subscription_handler.dart",
      "subscribe for area - RegisterAreaError",
      e.toString(),
    );
    if (!context.mounted) return;
    LoadingScreen.instance().show(
      context: context,
      text:
          localizations.add_my_place_with_map_loading_screen_subscription_error,
    );
    await Future.delayed(
      const Duration(seconds: 5),
    );
    LoadingScreen.instance().hide();
    rethrow;
  } on SocketException catch (e) {
    ErrorLogger.writeErrorLog(
      "subscription_handler.dart",
      "subscribe for area - SocketException",
      e.toString(),
    );
    if (!context.mounted) return;
    LoadingScreen.instance().show(
      context: context,
      text:
          localizations.add_my_place_with_map_loading_screen_subscription_error,
    );
    await Future.delayed(
      const Duration(seconds: 5),
    );
    LoadingScreen.instance().hide();
    rethrow;
  }
  if (subscriptionId != "") {
    if (!context.mounted) return;
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
}
