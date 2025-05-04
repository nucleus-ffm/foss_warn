import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:share_plus/share_plus.dart';

import '../class/class_error_logger.dart';

class LogFileViewer extends StatefulWidget {
  const LogFileViewer({super.key});

  @override
  State<LogFileViewer> createState() => _LogFileViewerState();
}

class _LogFileViewerState extends State<LogFileViewer> {
  // used to scroll horizontal and vertical at the same time
  final ScrollController _horizontal = ScrollController(),
      _vertical = ScrollController();

  Future<void> shareText(
    BuildContext context,
    String shareText,
    String shareSubject,
  ) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      shareText,
      subject: shareSubject,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    var localization = context.localizations;
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.error_log_viewer_title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(localization.error_log_viewer_headline),
            FutureBuilder<String>(
              future: ErrorLogger.readLog(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    final String log = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Divider(),
                          ),
                          SizedBox(
                            height: 500,
                            child: Scrollbar(
                              controller: _horizontal,
                              thumbVisibility: true,
                              trackVisibility: true,
                              notificationPredicate: (notify) =>
                                  notify.depth == 1,
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  shareText(
                                    context,
                                    log,
                                    localization.error_log_share_info,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                child: Text(
                                  localization.error_log_button_share,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  ErrorLogger.deleteLog();
                                  setState(() {});
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                                child: Text(
                                  localization.error_log_button_delete,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onError,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else {
                    debugPrint(
                      "Error getting system information: ${snapshot.error}",
                    );
                    return const Text(
                      "Error",
                      style: TextStyle(color: Colors.red),
                    );
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
