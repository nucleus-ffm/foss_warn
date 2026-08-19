import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foss_warn/extensions/context.dart';
import '../../services/collect_system_info.dart';

class SystemInformationDialog extends StatefulWidget {
  const SystemInformationDialog({super.key});

  @override
  State<SystemInformationDialog> createState() =>
      _SystemInformationDialogState();
}

class _SystemInformationDialogState extends State<SystemInformationDialog> {
  @override
  Widget build(BuildContext context) {
    var localization = context.localizations;
    return FutureBuilder<String>(
      future: collectSystemInfo(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final String data = snapshot.data!;
            debugPrint(data);
            return AlertDialog(
              title: Text(localization.system_information_dialog_title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(data),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: data));
                    final snackBar = SnackBar(
                      content: Text(
                        localization.system_information_copy_confirmation,
                        style: const TextStyle(color: Colors.black),
                      ),
                      backgroundColor: Colors.green[100],
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: Text(
                    localization.system_information_copy_action,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    localization.main_dialog_close,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            );
          } else {
            debugPrint("Error getting system information: ${snapshot.error}");
            return const Text("Error", style: TextStyle(color: Colors.red));
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
