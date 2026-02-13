import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

import '../constants.dart' as constants;
import 'class_error_logger.dart';
import 'class_user_preferences.dart';

///
/// ID 2: Status notification
/// ID 3: No Places selected warning
/// ID 4: legacy warning
/// ID 5: subscription error
class NotificationService {
  static String notificationGroupKey = "FOSSWarnNotifications";
  static final _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();

  static NotificationDetails _notificationsDetails(
    String channelId,
    String channelName,
  ) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
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

  // show a notification
  static Future showNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
    required String channelId,
    required String channelName,
    required UserPreferences userPreferences,
    String? alertID,
  }) async {
    _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      _notificationsDetails(channelId, channelName),
      payload: payload,
    );
    showGroupNotification();
    if (userPreferences.enableFOSSWarnAtHome) {
      // send notification to FOSSWarn@Home connector
      // this sends the title of the alert
      // write the message to a named pipe for the IPC
      final command =
          "echo '{\"title\": \"$title\", \"body\": \"$body\", \"severity\": \"$channelId\"}' > /tmp/fosswarn@home_pipe";
      print("run command $command"); //@TODO remove
      Process.run('/bin/bash', ['-c', command]).then((result) {
        stdout.write(result.stdout);
        stderr.write(result.stderr);
      });

      if(alertID != null && userPreferences.fossWarnTVAddress != "") {

        // send request to TV
        var url = Uri.parse(
          "${userPreferences.fossWarnTVAddress}:8080/show_alert?id=$alertID",
        );
        print("Sending command to TV on address $url");

        var response = await http.get(
          url,
          headers: {
            "Content-Type": "application/json",
            'User-Agent': constants.httpUserAgent,
          },
        );
        debugPrint(response.toString());
      } else {
        print("No TV address configured. ${userPreferences.fossWarnTVAddress} "
            "or no id: $alertID");
      }

    }
  }

  // @TODO(Nucleus): refactor this
  static Future<void> showGroupNotification() async {
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'foss_warn',
        'Notifications',
        channelDescription: 'FOSSWarn Notifications',
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
    await _flutterLocalNotificationsPlugin.show(
      0,
      "Alerts",
      "There are multiple alerts",
      notificationDetails,
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
    ); //onSelectNotification
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

  /// [Android only]
  /// Function to remove all deprecated notification channels
  static Future<void> cleanUpNotificationChannels() async {
    if (!Platform.isAndroid) {
      return;
    }
    debugPrint("Check notification channels and remove deprecated ones");
    List<String> currentNotificationChannelIds = [];
    currentNotificationChannelIds
        .add("de.nucleus.foss_warn.notifications_minor");
    currentNotificationChannelIds
        .add("de.nucleus.foss_warn.notifications_moderate");
    currentNotificationChannelIds
        .add("de.nucleus.foss_warn.notifications_severe");
    currentNotificationChannelIds
        .add("de.nucleus.foss_warn.notifications_extreme");
    currentNotificationChannelIds
        .add("de.nucleus.foss_warn.notifications_state");
    currentNotificationChannelIds
        .add("de.nucleus.foss_warn.notifications_other");
    currentNotificationChannelIds
        .add("de.nucleus.foss_warn.notifications_update");

    List<AndroidNotificationChannel>? notificationChannels =
        (await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.getNotificationChannels());
    for (AndroidNotificationChannel channel in notificationChannels!) {
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

    List<AndroidNotificationChannel> notificationChannels = [
      AndroidNotificationChannel(
        "de.nucleus.foss_warn.notifications_minor",
        localizations.notification_settings_notify_by_minor,
        description:
            localizations.warning_severity_explanation_dialog_minor_description,
        groupId: "de.nucleus.foss_warn.notification_group",
        importance: Importance.max,
      ),
      AndroidNotificationChannel(
        "de.nucleus.foss_warn.notifications_moderate",
        localizations.notification_settings_notify_by_moderate,
        description: localizations
            .warning_severity_explanation_dialog_moderate_description,
        groupId: "de.nucleus.foss_warn.notification_group",
        importance: Importance.max,
      ),
      AndroidNotificationChannel(
        "de.nucleus.foss_warn.notifications_severe",
        localizations.notification_settings_notify_by_severe,
        description: localizations
            .warning_severity_explanation_dialog_severe_description,
        groupId: "de.nucleus.foss_warn.notification_group",
        importance: Importance.max,
      ),
      AndroidNotificationChannel(
        "de.nucleus.foss_warn.notifications_extreme",
        localizations.notification_settings_notify_by_extreme,
        description: localizations
            .warning_severity_explanation_dialog_extreme_description,
        groupId: "de.nucleus.foss_warn.notification_group",
        importance: Importance.max,
      ),
      AndroidNotificationChannel(
        "de.nucleus.foss_warn.notifications_update",
        localizations.notification_settings_notify_by_update,
        description: localizations
            .warning_severity_explanation_dialog_update_description,
        groupId: "de.nucleus.foss_warn.notification_group",
        importance: Importance.low,
      ),
      AndroidNotificationChannel(
        "de.nucleus.foss_warn.notifications_other",
        localizations.notification_channel_other_name,
        description: localizations.notification_channel_other_description,
        groupId: "de.nucleus.foss_warn.notification_group",
        importance: Importance.defaultImportance,
      ),
    ];

    final androidNotificationPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidNotificationPlugin != null) {
      // init the different notifications channels/groups
      try {
        // create notification group for grouping multiple notifications
        await androidNotificationPlugin.createNotificationChannelGroup(
          AndroidNotificationChannelGroup(
            "de.nucleus.foss_warn.notification_group",
            localizations.notification_group_name,
            description: localizations.notification_group_description,
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
        ErrorLogger.writeErrorLog(
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
  static Future<void> cancelOneNotification(id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);

    // cancel summery notification if it is the last one
    List<ActiveNotification>? activeNotifications =
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.getActiveNotifications();

    if (activeNotifications != null &&
        activeNotifications.length == 2 &&
        activeNotifications.any(
          (element) =>
              element.channelId == "de.nucleus.foss_warn.notifications_state",
        )) {
      if (activeNotifications[0].id == 0) {
        // summery notification has id 0
        cancelOneNotification(0);
      }
    }
  }

  /// cancel all notifications
  static Future<void> cancelAllNotification() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Check if a notification with the given id is currently active
  static Future<bool> isNotificationActive(int id) async {
    // getActiveNotifications will throw a UnimplementedError
    if (Platform.isIOS || Platform.isAndroid || Platform.isMacOS) {
      List<ActiveNotification> activeNotification =
          await _flutterLocalNotificationsPlugin.getActiveNotifications();
      return activeNotification.any(
        (notification) => notification.id != null && notification.id == id,
      );
    }
    // on Linux we do not know
    return false;
  }
}
