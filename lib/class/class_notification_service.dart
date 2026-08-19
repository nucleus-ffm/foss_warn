import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

import '../enums/notification_channel.dart';
import 'class_error_logger.dart';

/// Notification channel group ids
const String notificationChannelGroupAlerts =
    "de.nucleus.foss_warn.notification__channel_group_alerts";
const String notificationChannelGroupOther =
    "de.nucleus.foss_warn.notification_channel_group_other";

/// key that is used to group multiple notifications
const String notificationGroupKey =
    "de.nucleus.foss_warn.notification_group_key";

/// ID 0: Notification summary
/// ID 2: Status notification
/// ID 3: No Places selected warning
/// ID 4: legacy warning
/// ID 5: subscription error
class NotificationService {
  static final _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();

  /// Build the notification Details for the given channel id and name
  static NotificationDetails _getNotificationsDetails(
    NotificationChannel notificationChannel,
  ) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        notificationChannel.channelId,
        "", //@TODO: Add a defensive default here
        groupKey: notificationGroupKey,
        category: AndroidNotificationCategory.message,
        priority: Priority.max,

        // enable multiline notification
        styleInformation: const BigTextStyleInformation(''),
        color: Colors.red, // makes the icon red,
        ledColor: Colors.red,
        ledOffMs: 100,
        ledOnMs: 100,
      ),
      linux: const LinuxNotificationDetails(),
    );
  }

  /// Notification summary details
  static NotificationDetails _getNotificationSummaryDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationChannel.summary.channelId,
        "",
        channelDescription: '',
        groupKey: notificationGroupKey,
        setAsGroupSummary: true,
        importance: Importance.max,
        priority: Priority.max,
        playSound: false,

        // enable multiline notification
        styleInformation: const BigTextStyleInformation(''),
        color: Colors.red, // makes the icon red,
        ledColor: Colors.red,
        ledOffMs: 100,
        ledOnMs: 100,
      ),
      linux: const LinuxNotificationDetails(),
    );
  }

  // show a notification
  static Future showNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
    required NotificationChannel channel,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      _getNotificationsDetails(channel),
      payload: payload,
    );
    await showNotificationSummary();
  }

  /// Show a notification summary. This is used on Android < 7.0 instead of the collabsed
  /// notification. On Android 7.0+ the text of this notification is not shown
  static Future<void> showNotificationSummary() async {
    List<ActiveNotification>? activeNotifications = [];
    try {
      activeNotifications = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.getActiveNotifications();
    } on PlatformException {
      // not supported on this platform
    }
    // build a short summary of every active notification
    String notificationBody = "";
    if (activeNotifications != null && activeNotifications.isNotEmpty) {
      for (ActiveNotification notification in activeNotifications) {
        notificationBody += notification.title ?? "";
        notificationBody += " ";
        if (notification.body != null) {
          notificationBody += notification.body!
              .substring(0, min(notification.body!.length, 50));
        }
        notificationBody += "\n";
      }
    }

    await _flutterLocalNotificationsPlugin.show(
      0,
      null, // we do not need a title here
      notificationBody,
      _getNotificationSummaryDetails(),
    );
  }

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'open',
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      linux: initializationSettingsLinux,
    );

    // when App is closed
    // https://pub.dev/packages/flutter_local_notifications#linux-limitations
    if (!Platform.isLinux) {
      final details = await _flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();
      if (details != null &&
          details.notificationResponse != null &&
          details.didNotificationLaunchApp) {
        onNotification.add(details.notificationResponse!.payload);
      }
    }

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  /// [Android only]
  /// Request notification permission on Android. This methode is currently
  /// used in the welcome view. This should later be migrated into a cross
  /// platform solution
  Future<bool?> requestNotificationPermission() async {
    final androidNotificationPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidNotificationPlugin != null) {
      // Request notifications permission (Android 13+)
      return await androidNotificationPlugin.requestNotificationsPermission();
    } else {
      return null;
    }
  }

  Future<bool?> requestAlarmPermission() async {
    final androidNotificationPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidNotificationPlugin != null) {
      // Request notifications permission (Android 13+)
      return await androidNotificationPlugin.requestExactAlarmsPermission();
    } else {
      return null;
    }
  }

  /// [Android only]
  /// Function to remove all deprecated notification channels
  static Future<void> cleanUpNotificationChannels() async {
    if (!Platform.isAndroid) {
      return;
    }
    debugPrint("Check notification channels and remove deprecated ones");
    List<String> currentNotificationChannelIds = [];

    for (var e in NotificationChannel.values) {
      currentNotificationChannelIds.add(e.channelId);
    }

    List<AndroidNotificationChannel>? notificationChannels =
        (await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.getNotificationChannels());
    for (AndroidNotificationChannel channel
        in notificationChannels ?? const []) {
      debugPrint("Checking channel with id: ${channel.id}}");
      if (currentNotificationChannelIds.contains(channel.id)) {
        debugPrint("Channel ${channel.id} is correct and not deleted");
      } else {
        // remove old channel
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.deleteNotificationChannel(channel.id);
        debugPrint("delete old notification channel: ${channel.id}");
      }
    }
  }

  /// [Android only]
  /// create all notification channels with name and description
  static Future<void> createNotificationChannels(BuildContext context) async {
    if (!Platform.isAndroid) {
      return;
    }
    var localizations = context.localizations;
    // create list of channel we want to have
    // split channels into two groups:
    //      notificationChannelGroupAlerts => every channel that publishes alerts
    //      notificationChannelGroupOther => every other channel
    List<AndroidNotificationChannel> notificationChannels = [
      AndroidNotificationChannel(
        NotificationChannel.minor.channelId,
        NotificationChannel.minor.getLocalizedName(context),
        description: NotificationChannel.minor.getLocalizedDescription(context),
        groupId: notificationChannelGroupAlerts,
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        NotificationChannel.moderate.channelId,
        NotificationChannel.moderate.getLocalizedName(context),
        description:
            NotificationChannel.moderate.getLocalizedDescription(context),
        groupId: notificationChannelGroupAlerts,
        importance: Importance.max,
      ),
      AndroidNotificationChannel(
        NotificationChannel.severe.channelId,
        NotificationChannel.severe.getLocalizedName(context),
        description:
            NotificationChannel.severe.getLocalizedDescription(context),
        groupId: notificationChannelGroupAlerts,
        importance: Importance.max,
      ),
      AndroidNotificationChannel(
        NotificationChannel.extreme.channelId,
        NotificationChannel.extreme.getLocalizedName(context),
        description:
            NotificationChannel.extreme.getLocalizedDescription(context),
        groupId: notificationChannelGroupAlerts,
        importance: Importance.max,
      ),
      AndroidNotificationChannel(
        NotificationChannel.update.channelId,
        NotificationChannel.update.getLocalizedName(context),
        description:
            NotificationChannel.update.getLocalizedDescription(context),
        groupId: notificationChannelGroupAlerts,
        importance: Importance.low,
      ),
      AndroidNotificationChannel(
        NotificationChannel.summary.channelId,
        NotificationChannel.summary.getLocalizedName(context),
        description:
            NotificationChannel.summary.getLocalizedDescription(context),
        groupId: notificationChannelGroupAlerts,
        importance: Importance.low,
      ),
      // Channel for general purpose notification, not used for alerts
      AndroidNotificationChannel(
        NotificationChannel.other.channelId,
        NotificationChannel.other.getLocalizedName(context),
        description: NotificationChannel.other.getLocalizedDescription(context),
        groupId: notificationChannelGroupOther,
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        NotificationChannel.debug.channelId,
        NotificationChannel.debug.getLocalizedName(context),
        description: NotificationChannel.debug.getLocalizedDescription(context),
        groupId: notificationChannelGroupOther,
        importance: Importance.defaultImportance,
      ),
    ];

    final androidNotificationPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidNotificationPlugin != null) {
      // init the different notifications channels/groups
      try {
        // create notification group for grouping multiple notification channels
        await androidNotificationPlugin.createNotificationChannelGroup(
          AndroidNotificationChannelGroup(
            notificationChannelGroupAlerts,
            localizations.notification_channel_group_alerts_name,
            description:
                localizations.notification_channel_group_alerts_description,
          ),
        );
        await androidNotificationPlugin.createNotificationChannelGroup(
          AndroidNotificationChannelGroup(
            notificationChannelGroupOther,
            localizations.notification_channel_group_other_name,
            description:
                localizations.notification_channel_group_other_description,
          ),
        );

        // create all notification channels
        for (var channel in notificationChannels) {
          await androidNotificationPlugin.createNotificationChannel(
            channel,
          );
        }
      } catch (e) {
        debugPrint("Error while creating notification channels: $e");
        ErrorLogger.writeLog(
          "class_NotificationService.dart",
          "Error while creating notification channels",
          e.toString(),
        );
      }
    }
  }

  Future<void> onDidReceiveNotificationResponse(
    NotificationResponse? notificationResponse,
  ) async {
    debugPrint("Notification clicked");
    debugPrint(notificationResponse?.payload);
    onNotification.add(notificationResponse?.payload);
  }

  /// cancel one notification with the given id
  static Future<void> cancelOneNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);

    // cancel summery notification if it is the last one
    final active = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.getActiveNotifications() ??
        const [];
    // only the summary (id 0) is left -> remove it as well
    final remaining = active.where((n) => n.id != 0);
    if (remaining.isEmpty) {
      await _flutterLocalNotificationsPlugin.cancel(0);
    }
  }

  /// cancel all notifications
  static Future<void> cancelAllNotification() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Check if a notification with the given id is currently active
  static Future<bool> isNotificationActive(int id) async {
    List<ActiveNotification> activeNotification =
        await _flutterLocalNotificationsPlugin.getActiveNotifications();
    return activeNotification.any(
      (notification) => notification.id != null && notification.id == id,
    );
  }
}
