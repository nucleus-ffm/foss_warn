import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/services/warnings.dart';

import '../class/class_error_logger.dart';
import '../class/class_notification_service.dart';
import '../class/class_user_preferences.dart';
import '../class/class_warn_message.dart';
import '../enums/notification_message_type.dart';
import 'alert_api/fpas.dart';
import 'api_handler.dart';

/// handles the incoming push notifications
void handleIncomingNotification(var rawPayload, WidgetRef ref) {
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
        newAlertNotification(payload, ref);
      case NotificationMessageType.subscribe:
        subscriptionConfirmationNotification(payload, ref);
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
    );
  }
}

Future<void> newAlertNotification(
  Map<String, dynamic> payload,
  WidgetRef ref,
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
      if (checkIfEventShouldBeNotified(
        alert.info[0].severity,
        userPreferences,
      )) {
        NotificationService.showNotification(
          id: alert.identifier.hashCode,
          title: "New alert",
          body: alert.info.first.headline,
          payload: "",
          channelId:
              "de.nucleus.foss_warn.notifications_${alert.info[0].severity.name}",
          channelName: "",
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
  );
}
