import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foss_warn/class/class_ErrorLogger.dart';
import 'package:foss_warn/main.dart';

class ErrorDialog extends StatefulWidget {
  const ErrorDialog({Key? key}) : super(key: key);

  @override
  _ErrorDialogState createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {
  // used to scroll horizontal and vertical at the same time
  final ScrollController _horizontal = ScrollController(),
      _vertical = ScrollController();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: ErrorLogger.readLog(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final String log = snapshot.data!;
            //print(log);
            return AlertDialog(
              title: Text("Oh no - something went wrong :("),
              content: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FOSS Warn has noticed an error."
                      " Please contact the developer and attach the following log:",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                        "The log does not contain any privacy sensitive information beside maybe your selected place. "
                        "FOSS Warn also does not send any log information to a server."),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "What should I do now?",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text("write an E-Mail to: foss_warn@posteo.de"),
                    Text("or open an Github Issue"),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Divider(),
                    ),
                    Expanded(
                      child: Container(
                        child: Scrollbar(
                          controller: _horizontal,
                          thumbVisibility: true,
                          trackVisibility: true,
                          notificationPredicate: (notify) => notify.depth == 1,
                          child: SingleChildScrollView(
                            controller: _vertical,
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              controller: _horizontal,
                              scrollDirection: Axis.horizontal,
                              child: Text(log),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: !appState.error,
                          onChanged: (value) {
                            setState(() {
                              appState.error = !(value ?? true);
                            });
                          },
                        ),
                        Text("Do not show message again"),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: log));
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
            print("Error getting system information: ${snapshot.error}");
            return Text("Error", style: TextStyle(color: Colors.red));
          }
        } else
          return CircularProgressIndicator();
      },
    );
  }
}
