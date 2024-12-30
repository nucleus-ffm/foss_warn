import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return FutureBuilder<String>(
        future: collectSystemInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final String data = snapshot.data!;
              debugPrint(data);
              return AlertDialog(
                title: Text("Systeminformationen"),
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
                        content: const Text(
                          "Kopiert",
                          style: TextStyle(color: Colors.black),
                        ),
                        backgroundColor: Colors.green[100],
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    child: Text("Kopieren",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Schließen",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary)),
                  ),
                ],
              );
            } else {
              debugPrint("Error getting system information: ${snapshot.error}");
              return Text("Error", style: TextStyle(color: Colors.red));
            }
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
