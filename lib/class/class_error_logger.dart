import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class ErrorLogger {
  static Future<String> get _localPath async {
    var directory = await getApplicationSupportDirectory();
    if (Platform.isAndroid) {
      directory = await getApplicationDocumentsDirectory();
    }
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    String errorLogPath = UserPreferences.errorLogPath;
    return File('$path/$errorLogPath');
  }

  /// deletes the log file from storage
  static Future<bool> deleteLog() async {
    try {
      final file = await _localFile;
      // delete the file
      await file.delete();
      return true;
    } catch (e) {
      // If encountering an error, return 0
      debugPrint("Error while reading error: ${e.toString()}");
      return false;
    }
  }

  /// reads the logfile and returns the result als String
  static Future<String> readLog() async {
    try {
      final file = await _localFile;
      // Read the file
      var log = await file.readAsString();
      return log;
    } catch (e) {
      // If encountering an error, return 0
      debugPrint("Error while reading logfile: ${e.toString()}");
      return "Error. Can not read logfile. No logfile to display.";
    }
  }

  static String _generateLogContent(
    String fileContext,
    String logContext,
    String logMessage,
  ) {
    return "${DateTime.now().toString()} | FileContext: $fileContext |  Context: $logContext | Message: $logMessage \n\n";
  }

  /// write message to logfile
  /// loContext: In which context the message or error occurred. e.g. json parsing in class xy
  /// logMessage: the Message to log e.g. the thrown exception
  static Future<void> writeLog(
    String fileContext,
    String logContext,
    String logMessage,
  ) async {
    final file = await _localFile;
    final raf = await file.open(mode: FileMode.append);
    // use blockingExclusive to be able to wait for the file to be free
    await raf.lock(FileLock.blockingExclusive);
    try {
      await raf.writeString(
        _generateLogContent(fileContext, logContext, logMessage.toString()),
      );
      await raf.unlock();
    } catch (e) {
      debugPrint("Error while writing log ${e.toString()}");
    } finally {
      await raf.close();
    }
  }
}
