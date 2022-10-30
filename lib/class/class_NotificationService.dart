import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foss_warn/services/helperFunctionToTranslateAndChooseColorTyp.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();

  static Future _notificationsDetails(String channel) async {
    return NotificationDetails(
        android: AndroidNotificationDetails(
          'foss_warn_notifications_' + channel,
          "Warnstufe: " + translateMessageSeverity(channel),
          channelDescription: 'FOSS Warn notifications',
          groupKey: "FossWarn",
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
          'foss_warn_status', 'Statusanzeige',
          channelDescription: 'Status der Hintergrund Updates',
          groupKey: "FossWarnStatus",
          importance: Importance.low,
          priority: Priority.min,
          playSound: false,

          //@TODO: show an other icon for status notification
          //enable multiline notification
          styleInformation: BigTextStyleInformation(''),
          color: Colors.green, // makes the icon red,
        ),
        iOS: DarwinNotificationDetails());
  }

  static Future showNotification(
    int id,
    String? title,
    String? body,
    String? payload,
    String channel,
  ) async {
    flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      await _notificationsDetails(channel),
      payload: payload,
    );
    showGroupNotification();
  }

  static Future showStatusNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
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
          channelDescription: 'Foss Warn Benachrichtigungen',
          groupKey: "FossWarn",
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
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(AndroidNotificationChannel(
          'foss_warn_notifications_Minor', // id
          'Warnstufe: Gering', // title
          description: 'FOSS Warn notification', // description
          importance: Importance.max,
        ));

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(AndroidNotificationChannel(
          'foss_warn_notifications_Moderate', // id
          'Warnstufe: Mittel', // title
          description: 'FOSS Warn notification', // description
          importance: Importance.max,
        ));

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(AndroidNotificationChannel(
          'foss_warn_notifications_Severe', // id
          'Warnstufe: Schwer', // title
          description: 'FOSS Warn notification', // description
          importance: Importance.max,
        ));

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(AndroidNotificationChannel(
          'foss_warn_notifications_Extrem', // id
          'Warnstufe: Extrem', // title
          description: 'FOSS Warn notification', // description
          importance: Importance.max,
        ));

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

    /*print("[android notification channels]");
    List<AndroidNotificationChannel>? temp = (await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.getNotificationChannels());
    for(AndroidNotificationChannel p in temp! ) {
      print("id: " + p.id + " name: " + p.name);
    } */
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
