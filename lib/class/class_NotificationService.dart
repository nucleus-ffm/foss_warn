import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foss_warn/services/translateAndColorizeWarning.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

///
/// ID 2: Status notification
/// ID 3: No Places selected warning
/// ID 4: legacy warning
class NotificationService {
  static final _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();

  static Future _notificationsDetails(String channel) async {
    return NotificationDetails(
        android: AndroidNotificationDetails(
          'de.nucleus.foss_warn.notifications_' + channel.trim().toLowerCase(),
          "Warnstufe: " + translateWarningSeverity(channel),
          groupKey: "FossWarnWarnings",
          category: AndroidNotificationCategory.message,
          priority: Priority.max,

          // enable multiline notification
          styleInformation: BigTextStyleInformation(''),
          color: Colors.red, // makes the icon red,
          ledColor: Colors.red,
          ledOffMs: 100,
          ledOnMs: 100,
        ),
        iOS: DarwinNotificationDetails());
  }

  static Future _statusNotificationsDetails() async {
    return NotificationDetails(
        android: AndroidNotificationDetails(
          'de.nucleus.foss_warn.notifications_state',
          'Statusanzeige',
          channelDescription: 'Status der Hintergrund Updates',
          groupKey: "FossWarnService",
          category: AndroidNotificationCategory.service,
          importance: Importance.low,
          priority: Priority.min,
          playSound: false,
          channelShowBadge: false,
          ongoing: true, // to prevent canceling

          //@TODO: show an other icon for status notification
          //enable multiline notification
          styleInformation: BigTextStyleInformation(''),
          color: Colors.green, // makes the icon green,
        ),
        iOS: DarwinNotificationDetails());
  }

  // show a notification // with named parameters
  static Future showNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
    required String channel,
  }) async {
    _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      await _notificationsDetails(channel),
      payload: payload,
    );
    showGroupNotification();
  }

  static Future showStatusNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
  }) async {
    _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      await _statusNotificationsDetails(),
      payload: payload,
    );
  }

  static void showGroupNotification() async {
    NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'foss_warn', 'Benachrichtigungen',
          channelDescription: 'FOSS Warn Benachrichtigungen',
          groupKey: "FossWarnWarnings",
          setAsGroupSummary: true,
          importance: Importance.max,
          priority: Priority.max,
          playSound: false,

          //enable multiline notification
          styleInformation: BigTextStyleInformation(''),
          color: Colors.red, // makes the icon red,
          ledColor: Colors.red,
          ledOffMs: 100,
          ledOnMs: 100,
        ),
        iOS: DarwinNotificationDetails());
    await _flutterLocalNotificationsPlugin.show(0, "Warnungen",
        "Es gibt für mehrere Orte Warnungen", notificationDetails);
  }

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      //onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: null);

    final androidNotificationPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidNotificationPlugin != null) {
      // Request notifications permission (Android 13+)
      await androidNotificationPlugin.requestNotificationsPermission();

      // Request schedule exact alarm permission (Android 14+)
      await androidNotificationPlugin.requestExactAlarmsPermission();

      // init the different notifications channels
      try {
        await androidNotificationPlugin.createNotificationChannelGroup(
            AndroidNotificationChannelGroup(
                "de.nucleus.foss_warn.notifications_emergency_information",
                "Gefahreninformationen",
                description: "Benachrichtigungen zu Gefahrenmeldungen"));

        await androidNotificationPlugin.createNotificationChannelGroup(
            AndroidNotificationChannelGroup(
                "de.nucleus.foss_warn.notifications_other", "Sonstiges",
                description: "Sonstige Benachrichtigungen"));

        await androidNotificationPlugin
            .createNotificationChannel(AndroidNotificationChannel(
          "de.nucleus.foss_warn.notifications_minor",
          "Warnstufe: Gering",
          description:
              "Warnung vor einer Beeinträchtigung des normalen Tagesablaufs.",
          groupId: "de.nucleus.foss_warn.notifications_emergency_information",
          importance: Importance.max,
        ));

        await androidNotificationPlugin
            .createNotificationChannel(AndroidNotificationChannel(
          "de.nucleus.foss_warn.notifications_moderate",
          "Warnstufe: Moderat",
          description:
              "Eine Warnung vor einer starken Beeinträchtigung des normalen Tagesablaufs.",
          groupId: "de.nucleus.foss_warn.notifications_emergency_information",
          importance: Importance.max,
        ));

        await androidNotificationPlugin
            .createNotificationChannel(AndroidNotificationChannel(
          "de.nucleus.foss_warn.notifications_severe",
          "Warnstufe: Schwer",
          description:
              "Eine Warnung vor einer Gefahr, die ihre Gesundheit, ihr Eigentum und/oder öffentliche Infrastruktur beeinträchtigen kann.",
          groupId: "de.nucleus.foss_warn.notifications_emergency_information",
          importance: Importance.max,
        ));

        await androidNotificationPlugin
            .createNotificationChannel(AndroidNotificationChannel(
          "de.nucleus.foss_warn.notifications_extreme",
          "Warnstufe: Extrem",
          description:
              "Eine Warnung vor einer Gefahr, die sich kurzfristig signifikant auf ihre Gesundheit, ihr Eigentum und/oder öffentliche Infrastruktur auswirken kann.",
          groupId: "de.nucleus.foss_warn.notifications_emergency_information",
          importance: Importance.max,
        ));

        await androidNotificationPlugin
            .createNotificationChannel(AndroidNotificationChannel(
          "de.nucleus.foss_warn.notifications_state",
          "Statusanzeige",
          description: "Zeit den aktuellen Status der Hintergrundupdates an.",
          groupId: "de.nucleus.foss_warn.notifications_other",
          importance: Importance.low,
        ));

        await androidNotificationPlugin
            .createNotificationChannel(AndroidNotificationChannel(
          "de.nucleus.foss_warn.notifications_other",
          "Sonstiges",
          description: "Sonstige Benachrichtigungen",
          groupId: "de.nucleus.foss_warn.notifications_other",
          importance: Importance.defaultImportance,
        ));
      } catch (e) {
        print("Error while creating notification channels: " + e.toString());
      }
    }

    // when App is closed
    final details = await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
    if (details != null &&
        details.notificationResponse != null &&
        details.didNotificationLaunchApp) {
      onNotification.add(details.notificationResponse!.payload);
    }

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            onDidReceiveNotificationResponse); //onSelectNotification

    cleanUpNotificationChannels();
  }

  Future<void> cleanUpNotificationChannels() async {
    List<String> channelIds = [];
    channelIds.add("de.nucleus.foss_warn.notifications_minor");
    channelIds.add("de.nucleus.foss_warn.notifications_moderate");
    channelIds.add("de.nucleus.foss_warn.notifications_severe");
    channelIds.add("de.nucleus.foss_warn.notifications_extreme");
    channelIds.add("de.nucleus.foss_warn.notifications_state");
    channelIds.add("de.nucleus.foss_warn.notifications_other");

    print("[android notification channels]");
    List<AndroidNotificationChannel>? temp =
        (await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.getNotificationChannels());
    for (AndroidNotificationChannel p in temp!) {
      print("id: " + p.id + " name: " + p.name);
      if (channelIds.contains(p.id)) {
        print("Channel is correct and not deleted:" + p.id + " " + p.name);
      } else {
        // remove old channel
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.deleteNotificationChannel(p.id);
        print("delete notification channel: " + p.id + " " + p.name);
      }
    }
  }

  Future onDidReceiveNotificationResponse(
      NotificationResponse? notificationResponse) async {
    print("Notification clicked");
    print(notificationResponse?.payload);
    onNotification.add(notificationResponse?.payload);
    dynamic i = 1;
    return i;
  }

  /// cancel one notification with the given id
  static cancelOneNotification(id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);

    // cancel summery notification if it is the last one
    List<ActiveNotification>? activeNotifications =
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.getActiveNotifications();

    if (activeNotifications!.length == 2 &&
        activeNotifications
            .any((element) => element.channelId == "de.nucleus.foss_warn.notifications_state")) {
      if (activeNotifications[0].id == 0) {
        // summery notification has id 0
        cancelOneNotification(0);
      }
    }
  }

  /// cancel all notifications
  static cancelAllNotification() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
