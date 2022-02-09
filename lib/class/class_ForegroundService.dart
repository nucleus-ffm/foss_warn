// import 'dart:isolate';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import '../main.dart';

/*
class ForegroundService {

  Future<void> initForegroundService() async {
    print("init Foreground Service");
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'serviceNotification',
        channelName: 'FOSS Warn service notification',
        channelDescription: 'This notification is shown as long as FOSS Warn is running',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.MIN,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'notification_icon', //ic_notification_icon.png
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
      printDevLog: true,
    );
  }

  /*@override
  void initState() {
    //super.initState();
    _initForegroundTask();ReceivePort? _receivePort;
  }*/

  Future<bool> startForegroundServices() async {
    // You can save data using the saveData function.
    //await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    try {
      ReceivePort? receivePort;
      if (await FlutterForegroundTask.isRunningService) {
        receivePort = await FlutterForegroundTask.restartService();
      } else {
        receivePort = await FlutterForegroundTask.startService(
          notificationTitle: 'FOSS Warn ist aktiv',
          notificationText: 'letztes Updates: ',
          //callback: startCallback,
        );
      }
    } catch (e) {
      print("Error while start foreground service " + e.toString());
    }


    /*if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) {
        if (message is DateTime) {
          print('receive timestamp: $message');
        }
      });

      return true;
    } */
    return false;
  }

  Future<bool> updateForegroundServices(String updateTime) async {
    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    try {
      ReceivePort? receivePort;
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.updateService(
          notificationTitle: 'FOSS Warn ist aktiv',
          notificationText: 'letztes Updates: ' + updateTime + " Uhr",
          //callback: startCallback,
        );
      } else {
        startForegroundServices();
      }
    } catch (e) {
      print("Error while updating foreground service: " + e.toString());
    }


    /*if (receivePort != null) {
        _receivePort = receivePort;
        _receivePort?.listen((message) {
          if (message is DateTime) {
            print('receive timestamp: $message');
          }
        });

        return true;
      } */
    return false;
  }

    Future<bool> stopForegroundTask() async {
      return await FlutterForegroundTask.stopService();
    }

}
*/