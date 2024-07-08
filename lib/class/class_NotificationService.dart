import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foss_warn/enums/NotificationChannel.dart';
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
          NotificationChannel.state.id,
          'Statusanzeige',
          channelDescription: 'Status der Hintergrund Updates',
          groupKey: "FossWarnService",
          category: AndroidNotificationCategory.service,
          importance: Importance.low,
          priority: Priority.min,
          playSound: false,
          channelShowBadge: false,
          ongoing: true, // to prevent canceling

          // @todo: show different icon for status notification
          // enable multiline notification
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
      await androidNotificationPlugin.requestNotificationsPermission();
      await androidNotificationPlugin.requestExactAlarmsPermission();

      try {
        final String groupIdEmergencyInfo =
            "de.nucleus.foss_warn.notifications_emergency_information";
        final String groupIdOther = "de.nucleus.foss_warn.notifications_other";

        // init notification channel groups
        await androidNotificationPlugin.createNotificationChannelGroup(
            AndroidNotificationChannelGroup(
                groupIdEmergencyInfo, "Gefahreninformationen",
                description: "Benachrichtigungen zu Gefahrenmeldungen"));

        await androidNotificationPlugin.createNotificationChannelGroup(
            AndroidNotificationChannelGroup(groupIdOther, "Sonstiges",
                description: "Sonstige Benachrichtigungen"));

        // init notification channels
        await androidNotificationPlugin
            .createNotificationChannel(AndroidNotificationChannel(
          NotificationChannel.minor.id,
          "Warnstufe: Gering",
          description:
              "Warnung vor einer Beeinträchtigung des normalen Tagesablaufs.",
          groupId: groupIdEmergencyInfo,
          importance: Importance.max,
        ));

        await androidNotificationPlugin
            .createNotificationChannel(AndroidNotificationChannel(
          NotificationChannel.moderate.id,
          "Warnstufe: Moderat",
          description:
              "Eine Warnung vor einer starken Beeinträchtigung des normalen Tagesablaufs.",
          groupId: groupIdEmergencyInfo,
          importance: Importance.max,
        ));

        await androidNotificationPlugin
            .createNotificationChannel(AndroidNotificationChannel(
          NotificationChannel.severe.id,
          "Warnstufe: Schwer",
          description:
              "Eine Warnung vor einer Gefahr, die ihre Gesundheit, ihr Eigentum und/oder öffentliche Infrastruktur beeinträchtigen kann.",
          groupId: groupIdEmergencyInfo,
          importance: Importance.max,
        ));

        await androidNotificationPlugin
            .createNotificationChannel(AndroidNotificationChannel(
          NotificationChannel.extreme.id,
          "Warnstufe: Extrem",
          description:
              "Eine Warnung vor einer Gefahr, die sich kurzfristig signifikant auf ihre Gesundheit, ihr Eigentum und/oder öffentliche Infrastruktur auswirken kann.",
          groupId: groupIdEmergencyInfo,
          importance: Importance.max,
        ));

        await androidNotificationPlugin
            .createNotificationChannel(AndroidNotificationChannel(
          NotificationChannel.state.id,
          "Statusanzeige",
          description: "Zeit den aktuellen Status der Hintergrundupdates an.",
          groupId: groupIdOther,
          importance: Importance.low,
        ));

        await androidNotificationPlugin
            .createNotificationChannel(AndroidNotificationChannel(
          NotificationChannel.other.id,
          "Sonstiges",
          description: "Sonstige Benachrichtigungen",
          groupId: groupIdOther,
          importance: Importance.defaultImportance,
        ));
      } catch (e) {
        print("Error while creating notification channels: " + e.toString());
      }
    }

    // handle when the app is launched using a notification
    final details = await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      String? payload = details.notificationResponse?.payload;

      print("Notification was used to launch the app. Payload is: " + payload!);
      onNotification.add(payload);
    }

    // handle clicking a notification while the app is open
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (notificationResponse) {
      String? payload = notificationResponse.payload;

      print("Notification clicked while app was open. Payload is: " + payload!);
      onNotification.add(payload);
    }); //onSelectNotification

    cleanUpNotificationChannels();
  }

  Future<void> cleanUpNotificationChannels() async {
    final List<String> channelIds =
        NotificationChannel.values.map((channel) => channel.id).toList();

    AndroidFlutterLocalNotificationsPlugin? notificationsPlugin =
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
    List<AndroidNotificationChannel>? channels =
        await notificationsPlugin?.getNotificationChannels();

    if (channels == null) {
      print("[class_NotificiationService] No notification channels found");
      return;
    }

    print("[android notification channels]");
    for (AndroidNotificationChannel p in channels) {
      print("id: " + p.id + " name: " + p.name);

      if (channelIds.contains(p.id)) {
        print("Channel is correct and not deleted:" + p.id + " " + p.name);
      } else {
        // remove old channel
        await notificationsPlugin?.deleteNotificationChannel(p.id);
        print("delete notification channel: " + p.id + " " + p.name);
      }
    }
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
        activeNotifications.any(
            (element) => element.channelId == NotificationChannel.state.id)) {
      if (activeNotifications[0].id == 0) {
        // summary notification has id 0
        cancelOneNotification(0);
      }
    }
  }

  /// cancel all notifications
  static cancelAllNotification() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
