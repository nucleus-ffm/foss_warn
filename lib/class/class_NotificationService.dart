import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();

  static Future _notificationsDetails(String channel) async {
    return NotificationDetails(
        android: AndroidNotificationDetails(
          'foss_warn_notifications', channel, 'FOSS Warn Benachrichtigungen bei Warnmeldungen für hinterlegte Orte',
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
        iOS: IOSNotificationDetails());
  }

  static Future _statusNotificationsDetails() async {
    return NotificationDetails(
        android: AndroidNotificationDetails(
          'foss_warn_status', 'Statusanzeige', 'Status der Hintergrund Updates',
          groupKey: "FossWarnStatus",
          importance: Importance.low,
          priority: Priority.min,
          playSound: false,
          
          //@TODO: show an other icon for status notification
          //enable multiline notification
          styleInformation: BigTextStyleInformation(''),
          color: Colors.green, // makes the icon red,
        ),
        iOS: IOSNotificationDetails());
  }

  static Future showNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
    String channel = "Benachrichtigung",
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
      }) async {
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
          'foss_warn', 'Benachrichtigungen', 'Foss Warn Benachrichtigungen',
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
        iOS: IOSNotificationDetails());
    await flutterLocalNotificationsPlugin.show(0, "Warnungen",
        "Es gibt für mehrere Orte Warnungen", notificationDetails);
  }

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('res_notification_icon');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
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

    //when App is closed
    final details =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      onNotification.add(details.payload);
    }

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification); //onSelectNotification
  }

  Future onSelectNotification(String? payload) async {
    print("Notification clicked");
    print(payload);
    onNotification.add(payload);
    dynamic i = 1;
    return i;
  }

  static cancelOneNotification(id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    /* cancel summery notification if it is the last one */
    List<ActiveNotification>? activeNotifications =
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.getActiveNotifications();
    final List<PendingNotificationRequest> pendingNotificationRequests =
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    //@TODO: fix

    if (activeNotifications!.length == 2 && activeNotifications.any((element) => element.channelId == "foss_warn_status" )) {
      if (activeNotifications[0].id == 0) {
        // summery notification has id 0
        cancelOneNotification(0);
      }
    }
  }

  static cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
