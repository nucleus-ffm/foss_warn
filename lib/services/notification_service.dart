import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import '../main.dart';
import '../class/class_Place.dart';
import '../class/class_WarnMessage.dart';
import 'package:flutter/material.dart';
import '../MyPlacesView.dart';

class NotificationService {
  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();

  static Future _notificationsDetails() async {
    return NotificationDetails(
        android: AndroidNotificationDetails(
          'foss_warn', 'Benachrichtigungen', 'Foss Warn Benachrichtigungen',
          groupKey: "Foss.Warn",
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

  static Future showNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
  }) async {

    flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      await _notificationsDetails(),
      payload: payload,
    );

    //group Notifications
    List<ActiveNotification>? activeNotifications =
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.getActiveNotifications();

    if (activeNotifications!.length > 0) {

      List<String> lines = activeNotifications
          .map((notification) => notification.title.toString())
          .toList();
      InboxStyleInformation inboxStyleInformation = InboxStyleInformation(lines,
          contentTitle: "${activeNotifications.length+1} Warnungen",
          summaryText: "${activeNotifications.length+1} Warnungen");
      AndroidNotificationDetails groupNotificationDetails =
      AndroidNotificationDetails(
        'foss_warn', 'Benachrichtigungen', 'Foss Warn Benachrichtigungen',

        importance: Importance.max,
        priority: Priority.max,
        styleInformation: inboxStyleInformation,
        setAsGroupSummary: true,
        groupKey: "Foss.Warn",
        color: Colors.red, // makes the icon red,
        ledColor: Colors.blue,
        ledOffMs: 100,
        ledOnMs: 100,
      );
      NotificationDetails groupNotificationDetailsPlatformSpecifics =
          NotificationDetails(android: groupNotificationDetails);
      await flutterLocalNotificationsPlugin.show(0, "", "", groupNotificationDetailsPlatformSpecifics);

    }
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
  }
  static cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
