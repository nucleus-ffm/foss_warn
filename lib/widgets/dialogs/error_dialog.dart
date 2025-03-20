import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/main.dart';

class ErrorDialog extends ConsumerStatefulWidget {
  const ErrorDialog({super.key});

  @override
  ConsumerState<ErrorDialog> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends ConsumerState<ErrorDialog> {
  // used to scroll horizontal and vertical at the same time
  final ScrollController _horizontal = ScrollController(),
      _vertical = ScrollController();
  @override
  Widget build(BuildContext context) {
    var localization = context.localizations;

    return FutureBuilder<String>(
      future: ErrorLogger.readLog(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final String log = snapshot.data!;
            return AlertDialog(
              title: Text(localization.error_dialog_headline),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.error_dialog_description,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    localization.error_dialog_privacy,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    localization.error_dialog_instruction_headline,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    localization.error_dialog_instruction_body,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
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
                      Text(localization.error_dialog_hide_error_bar),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: log));
                    final snackBar = SnackBar(
                      content: Text(
                        localization.error_dialog_copy_success,
                        style: const TextStyle(color: Colors.black),
                      ),
                      backgroundColor: Colors.green[100],
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: Text(
                    localization.error_dialog_copy,
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
