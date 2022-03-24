// import 'dart:isolate';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import '../main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';

import '../main.dart';


class ForegroundService {

  Future<void> initForegroundService() async {
    print("init Foreground Service");


    var hasPermissions = await FlutterBackground.hasPermissions;
    if (!hasPermissions) {
      await showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) {
            return AlertDialog(
                title: Text('Permissions needed'),
                content: Text(
                    'Shortly the OS will ask you for permission to execute this app in the background. This is required in order to receive chat messages when the app is not in the foreground.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ]);
          });
    }


    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "FOSS Warn ist aktiv",
      enableWifiLock: true,
      notificationText: "FOSS Warn läuft im Hintergrund",
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon: AndroidResource(name: 'ic_notification_icon', defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );

    hasPermissions = await FlutterBackground.initialize(androidConfig: androidConfig);


    if(hasPermissions) {
      print("starting background execution");
      bool backgroundExecution = await FlutterBackground.enableBackgroundExecution();
      if(backgroundExecution) {
        print("Background execution successfully started");
      } else {
        print("Background execution failed while starting");
      }
    } else {
      print("can not ebale background service because of missing permissions");
    }

  }

  /*@override
  void initState() {
    //super.initState();
    _initForegroundTask();ReceivePort? _receivePort;
  }*/

  Future startForegroundServices() async {
    FlutterBackground.enableBackgroundExecution();
  }

  Future stopForegroundServices() async {
    await FlutterBackground.disableBackgroundExecution();
  }

  /*
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
  */
}
