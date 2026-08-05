import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_error_logger.dart';
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
  static Future<AlertArchive> create(Ref ref) async {
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
  static Future<List<WarnMessage>> readArchive(Ref ref) async {
    try {
      final file = await _localFile;
      String archive = await file.readAsString().catchError((_) => '[]');
      final List<dynamic> jsonList = jsonDecode(archive) as List<dynamic>;

      List<WarnMessage> result = [];
      for (final item in jsonList) {
        if (item is! Map<String, dynamic>) continue;

        final alert = WarnMessage.fromJson(
          item,
          fpasId: item['fpasId'],
          placeId: constants.noPlaceId,
        );
        ref.read(processedAlertsProvider.notifier).updateAlert(alert);
        result.add(alert);
      }
      return result;
    } catch (e) {
      // If encountering an error, return 0
      debugPrint("Error while reading archive: ${e.toString()}");
      ErrorLogger.writeLog(
        "class_alert_archive",
        "Error while reading archive",
        e.toString(),
      );
      return [];
    }
  }

  /// write the given alert to the archive
  ///
  /// We need some kind of mutex to prevent broken json files
  static Future<void> writeAlertToArchive(
    WarnMessage alert,
  ) async {
    // we might want to check if the new alert is not already stored
    final file = await _localFile;
    final raf =
        await file.open(mode: FileMode.append); // do not truncate on open
    await raf.lock(FileLock.blockingExclusive);
    try {
      // start reading from the beginning of the file
      await raf.setPosition(0);
      final length = await raf.length();
      final bytes = length > 0 ? await raf.read(length) : <int>[];
      final content = bytes.isNotEmpty ? utf8.decode(bytes) : '[]';

      List<dynamic> alerts;
      try {
        alerts = jsonDecode(content) as List<dynamic>;
      } catch (e) {
        await ErrorLogger.writeLog(
          "class_alert_archive.dart",
          "writeAlertToArchive",
          "Error while adding alert ${e.toString()}",
        );
        alerts = [];
      }
      alerts.add(alert.toJson());
      final encoded = utf8.encode(jsonEncode(alerts));
      // ensure that we start writing at the start of the file
      await raf.setPosition(0);
      await raf.truncate(0);
      await raf.writeFrom(encoded);
    } catch (e) {
      debugPrint("Error while writing archive ${e.toString()}");
      await ErrorLogger.writeLog(
        "class_alert_archive.dart",
        "writeAlertToArchive",
        "Error while writing archive ${e.toString()}",
      );
    } finally {
      await raf.unlock();
      await raf.close();
    }
  }
}
