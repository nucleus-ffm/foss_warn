import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/services/warnings.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../constants.dart' as constants;

/// This allows to watch this provider and as soon as the provider is
/// not watched anymore, ths onDispose callback is trigger which
/// removes every archive alerts from the list
///
/// This might not be the best solution but is the simplest solution for now
final alertArchiveCleanupProvider = FutureProvider.autoDispose((ref) async {
  // This provider auto-disposes when no longer watched
  ref.onDispose(() {
    // Cleanup the archive alerts
    var alerts = ref.read(processedAlertsProvider);
    List<WarnMessage> alertsToDelete = [];
    alertsToDelete =
        alerts.where((alert) => alert.placeId == constants.noPlaceId).toList();
    ref
        .read(processedAlertsProvider.notifier)
        .deleteMultipleAlerts(alertsToDelete);
  });
  return null;
});

class AlertArchive {
  List<WarnMessage> alertArchive;

  AlertArchive({required this.alertArchive});

  /// create a new alertArchive object
  static Future<AlertArchive> create(WidgetRef ref) async {
    return AlertArchive(alertArchive: await readArchive(ref));
  }

  static Future<String> get _localPath async {
    var directory = await getApplicationSupportDirectory();
    if (Platform.isAndroid) {
      directory = await getApplicationDocumentsDirectory();
    }
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    String alertArchivePath = UserPreferences.alertArchivePath;
    return File('$path/$alertArchivePath');
  }

  /// deletes the log file from storage
  Future<bool> deleteArchive() async {
    try {
      final file = await _localFile;
      // delete the file
      file.delete();
      return true;
    } catch (e) {
      // If encountering an error, return 0
      debugPrint("Error while reading error: ${e.toString()}");
      return false;
    }
  }

  /// reads the archive and return the parse alerts
  static Future<List<WarnMessage>> readArchive(WidgetRef ref) async {
    try {
      final file = await _localFile;
      String archive = await file.readAsString();

      // there are not stored alerts
      if (archive.isEmpty) return [];

      // read the archive
      List<String> alerts = archive.split(";");
      List<WarnMessage> result = [];
      for (String alertString in alerts) {
        if (alertString == "") continue;
        Map<String, dynamic> alertJson = jsonDecode(alertString);
        WarnMessage alert = WarnMessage.fromJson(
          alertJson,
          fpasId: alertJson['fpasId'],
          placeId: constants.noPlaceId,
        );
        ref.read(processedAlertsProvider.notifier).updateAlert(alert);
        result.add(alert);
      }

      return result;
    } catch (e) {
      // If encountering an error, return 0
      debugPrint("Error while reading archive: ${e.toString()}");
      return [];
    }
  }

  /// write the given alert to the archive
  static Future<void> writeAlertToArchive(
    WarnMessage alert,
  ) async {
    // we might want to check if the new alert is not already stored
    try {
      final file = await _localFile;
      file.writeAsString(
        // store the alert separated with a ;
        "${jsonEncode(alert)};",
        mode: FileMode.append,
      );
    } catch (e) {
      debugPrint("Error while writing error log ${e.toString()}");
    }
  }
}
