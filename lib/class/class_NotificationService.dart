import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foss_warn/services/helperFunctionToTranslateAndChooseColorType.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();

  static Future _notificationsDetails(String channel) async {
    return NotificationDetails(
        android: AndroidNotificationDetails(
          'foss_warn_notifications_' + channel.trim().toLowerCase(),
          "Warnstufe: " + translateMessageSeverity(channel),
          channelDescription: 'FOSS Warn notifications for '+  channel.trim().toLowerCase(),
          groupKey: "FossWarnWarnings",
          category: AndroidNotificationCategory.alarm,
          importance: Importance.max,
          priority: Priority.max,

          //enable multiline notification
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
          'foss_warn_status',
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
          color: Colors.green, // makes the icon red,
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
    flutterLocalNotificationsPlugin.show(
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
  })  async {
    flutterLocalNotificationsPlugin.show(
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
    await flutterLocalNotificationsPlugin.show(0, "Warnungen",
        "Es gibt für mehrere Orte Warnungen", notificationDetails);
  }

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('res_notification_icon');

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

    // Request notifications permission (Android 13+)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    // init the different notifications channels
    try{
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(AndroidNotificationChannel("foss_warn_notifications_minor", "Warnstufe: Gering"));

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(AndroidNotificationChannel("foss_warn_notifications_moderate", "Warnstufe: Mittel"));

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(AndroidNotificationChannel("foss_warn_notifications_severe", "Warnstufe: Schwer"));

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(AndroidNotificationChannel("foss_warn_notifications_extreme", "Warnstufe: Extrem"));
    } catch(e) {
      print("Error while creating notification channels: " + e.toString());
    }

    // when App is closed
    final details =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null &&
        details.notificationResponse != null &&
        details.didNotificationLaunchApp) {
      onNotification.add(details.notificationResponse!.payload);
    }

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            onDidReceiveNotificationResponse); //onSelectNotification

    cleanUpNotificationChannels();
  }

  Future<void> cleanUpNotificationChannels() async {
    List<String> channelIds = [];
    channelIds.add("foss_warn_notifications_minor");
    channelIds.add("foss_warn_notifications_severe");
    channelIds.add("foss_warn_notifications_moderate");
    channelIds.add("foss_warn_notifications_extreme");
    channelIds.add("foss_warn_status");
    channelIds.add("foss_warn_other");

    print("[android notification channels]");
    List<AndroidNotificationChannel>? temp = (await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.getNotificationChannels());
    for(AndroidNotificationChannel p in temp! ) {
      print("id: " + p.id + " name: " + p.name);
      if(channelIds.contains(p.id)) {
        print("Channel is correct and not deleted:" + p.id + " " + p.name);
      }
      else {
        // remove old channel
        await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
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
    await flutterLocalNotificationsPlugin.cancel(id);

    // cancel summery notification if it is the last one
    List<ActiveNotification>? activeNotifications =
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.getActiveNotifications();

    if (activeNotifications!.length == 2 &&
        activeNotifications
            .any((element) => element.channelId == "foss_warn_status")) {
      if (activeNotifications[0].id == 0) {
        // summery notification has id 0
        cancelOneNotification(0);
      }
    }
  }

  /// cancel all notifications
  static cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
