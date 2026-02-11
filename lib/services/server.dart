import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/services/warnings.dart';

import '../class/class_warn_message.dart';
import '../routes.dart';
import 'alert_api/fpas.dart';


Future<void> handleTVCommands() async {
  // turn TV on
  const command =
      "echo \"on 0\" | cec-client -s -d 1";
  debugPrint("run command $command"); //@TODO remove
  Process.run('/bin/bash', ['-c', command]).then((result) {
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  });

  // wait 5 minutes to turn TV off again
  await Future.delayed(const Duration(minutes: 1));

  // turn TV off
  const commandOff =
      "echo \"standby 0\" | cec-client -s -d 1";
  debugPrint("run command $commandOff"); //@TODO remove
  Process.run('/bin/bash', ['-c', commandOff]).then((result) {
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  });
}

Future<void> handleRequest(HttpRequest request, WidgetRef ref) async{
  print("handle request $request");

  if (request.uri.path == '/show_alert') {
    final String? id = request.uri.queryParameters['id'];

    if(id != null) {
      WarnMessage alert = await ref.read(alertApiProvider).getAlertDetail(
        alertId: id,
        placeSubscriptionId: "Manually added",
      );
      ref.read(processedAlertsProvider.notifier).updateAlert(alert);

      var routes = ref.read(routesProvider);

      routes.go("/alerts/${alert.identifier}/1234");

      request.response
        ..statusCode = 200
        ..write('Showing alert')
        ..close();

      // do not wait for TV commands to finish as they are long running
      handleTVCommands();

    } else {
      request.response
        ..statusCode = 400
        ..write('Can not show alert without ID')
        ..close();
    }
  }
}

Future<void> startServer(WidgetRef ref) async {
  final server = await HttpServer.bind(
    InternetAddress.anyIPv4,
    8080,
  );
  debugPrint("Webserver is listening on http://localhost:8080");
  server.listen((request) => handleRequest(request, ref));
}

