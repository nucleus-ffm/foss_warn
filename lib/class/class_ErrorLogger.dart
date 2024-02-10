import 'package:foss_warn/class/class_userPreferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class ErrorLogger {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    String errorLogPath = UserPreferences().errorLogPath;
    // path /data/user/0/de.nucleus.foss_warn/app_flutter/errorLog.txt
    return File('$path/${errorLogPath}');
  }

  /// deletes the log file from storage
  static Future<bool> deleteLog() async {
    try {
      final file = await _localFile;
      // delete the file
      file.delete();
      return true;
    } catch (e) {
      // If encountering an error, return 0
      print("Error while reading error: ${e.toString()}");
      return false;
    }
  }

  /// reads the logfile and returns the result als String
  static Future<String> readLog() async {
    try {
      final file = await _localFile;
      // Read the file
      return await file.readAsString();
    } catch (e) {
      // If encountering an error, return 0
      print("Error while reading logfile: ${e.toString()}");
      return "error";
    }
  }

  static _generateLogContent(String fileContext, String errorContext, String errorMessage) {
    return "${DateTime.now().toString()} | FileContext: $fileContext |  ErrorContext: $errorContext | ErrorMessage: $errorMessage \n";
  }

  /// write error to logfile
  /// errorContext: In which context the error occur. e.g. json parsing in class xy
  /// errorMessage: the Message to log e.g. the thrown exception
  static writeErrorLog(String fileContext, String errorContext, String errorMessage) async {
    try {
      final file = await _localFile;
      // print(errorMessage);
      file.writeAsString(_generateLogContent(fileContext, errorContext, errorMessage),
          mode: FileMode.append);
    } catch (e) {
      print("Error while writing error log ${e.toString()}");
    }
  }
}
