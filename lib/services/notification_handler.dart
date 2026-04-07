import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_notification_preferences.dart';
import 'package:foss_warn/routes.dart';

import '../class/class_error_logger.dart';
import '../class/class_notification_service.dart';
import '../class/class_user_preferences.dart';
import '../class/class_warn_message.dart';
import '../enums/notification_message_type.dart';
import 'alert_api/fpas.dart';
import 'api_handler.dart';

/// handles the incoming push notifications
void handleIncomingNotification(
  var rawPayload,
  WidgetRef ref,
  BuildContext context,
) {
  // @TODO(Nucleus): This is not the perfect solution as we can not check for already read alerts or if the alert is just an update. It would be preferable if we could fetch all alerts like we did before. Currently, this results in a "concurrent modification during iteration" error if the app is launched by a notification.

  var userPreferences = ref.read(userPreferencesProvider);

  if (userPreferences.showDebugNotification) {
    handleDebugNotification(rawPayload, ref);
  }
  try {
    var payload = jsonDecode(rawPayload) as Map<String, dynamic>;

    NotificationMessageType messageType =
        NotificationMessageType.fromString(payload["type"]);

    switch (messageType) {
      case NotificationMessageType.added:
        newAlertNotification(payload, ref, context);
      case NotificationMessageType.subscribe:
        // @TODO this is not required for the home setup for now
        //subscriptionConfirmationNotification(payload, ref);
        break;
      case NotificationMessageType.unsubscribe:
        break; //@TODO (Nucleus): implement
      case NotificationMessageType.update:
        break; //@TODO (Nucleus): implement
      case NotificationMessageType.unknown:
        break; //@TODO (Nucleus): implement
    }
  } on FormatException catch (e) {
    debugPrint("Payload is not a json: $e");
  }
}

/// displays a notification with the raw message if case debug notifications
/// are enabled in the settings
void handleDebugNotification(String payload, WidgetRef ref) {
  var userPreferences = ref.read(userPreferencesProvider);

  if (userPreferences.showDebugNotification) {
    NotificationService.showNotification(
      id: Random().nextInt(100),
      title: "DEBUG Notification",
      body: "FOSSWarn has received a push notification with content: $payload",
      payload: "",
      channelId: "de.nucleus.foss_warn.notifications_other",
      channelName: "Debug notifications",
      userPreferences: ref.read(userPreferencesProvider),
    );
  }
}

Future<void> newAlertNotification(
  Map<String, dynamic> payload,
  WidgetRef ref,
  BuildContext context,
) async {
  var userPreferences = ref.read(userPreferencesProvider);
  String? addedAlertId;

  try {
    addedAlertId = payload["alert_id"];
    if (addedAlertId != null) {
      WarnMessage alert = await ref.read(alertApiProvider).getAlertDetail(
            alertId: addedAlertId,
            placeSubscriptionId: "Not used",
          );
      if (NotificationPreferences.checkIfEventShouldBeNotified(
        alert.info[0].severity,
        alert.info[0].category,
        userPreferences,
      )) {
        // push app to the screen with the alert
        var routes = ref.read(routesProvider);
        routes.go("/alerts/${alert.fpasId}/1234");

        List<String> categories = [];
        if (!context.mounted) {
          return;
        }
        for (var cat in alert.info.first.category) {
          categories.add(cat.getLocalizedName(context));
        }
        NotificationService.showNotification(
          id: alert.fpasId.hashCode,
          title: alert.info.first.headline,
          body: alert.info.first.description,
          severity: alert.info.first.severity.getLocalizedName(context),
          instructions: alert.info.first.instruction,
          categories: categories,
          sender: alert.sender,
          payload: "",
          channelId:
              "de.nucleus.foss_warn.notifications_${alert.info[0].severity.name}",
          channelName: "",
          userPreferences: ref.read(userPreferencesProvider),
          alertID: alert.fpasId,
        );
      }
    }
  } on AlertUnavailableError catch (e) {
    debugPrint("Alert is not available anymore: $e");
    ErrorLogger.writeErrorLog(
      "class_unified_push_handler.dart",
      "onMessage",
      "Alert $addedAlertId is not available anymore",
    );
  }
}

/// display a notification with the confirmation of the subscription
void subscriptionConfirmationNotification(
  Map<String, dynamic> payload,
  WidgetRef ref,
) {
  String confirmationId = payload["confirmation_id"];

  NotificationService.showNotification(
    id: confirmationId.hashCode,
    title: "Successfully subscribed",
    body: "You have successfully subscribed",
    payload: confirmationId,
    channelId: "de.nucleus.foss_warn.notifications_other",
    channelName: "",
    userPreferences: ref.read(userPreferencesProvider),
  );
}
