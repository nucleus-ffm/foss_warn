import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/main.dart';
import 'package:provider/provider.dart';

import '../../services/update_provider.dart';

class ErrorDialog extends StatefulWidget {
  const ErrorDialog({super.key});

  @override
  State<ErrorDialog> createState() => _ErrorDialogState();
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
              //@todo translate error_dialog_headline
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FOSS Warn has noticed an error."
                    " Please contact the developer and attach the following log:", //@todo translate error_dialog_text_introduction
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                      "The log does not contain any privacy sensitive information beside maybe your selected place. "
                      "FOSS Warn also does not send any log information to a server."), //@todo translate error_dialog_text_privacy
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "What should I do now?", // @todo translate error_dialog_text_instructions_headline
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text("write an E-Mail to: foss_warn@posteo.de"), // @toto translate error_dialog_text_instructions_text
                  Text("or open an Github Issue"),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Divider(),
                  ),
                  Expanded(
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
                      Text("hide error bar"), //@todo translate
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: log));
                    final snackBar = SnackBar(
                      content: const Text(
                        "copied", //@todo translate
                        style: TextStyle(color: Colors.black),
                      ),
                      backgroundColor: Colors.green[100],
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: Text("copy", //@todo translate
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary)),
                ),
                TextButton(
                  onPressed: () {
                    final updater = Provider.of<Update>(context, listen: false);
                    updater.updateView();
                    Navigator.of(context).pop();
                  },
                  child: Text("close", //@todo translate
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
      },
    );
  }
}
