import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_alert_archive.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/widgets/warning_widget.dart';

class AlertArchiveView extends ConsumerStatefulWidget {
  const AlertArchiveView({
    super.key,
    required this.onAlertPressed,
    required this.onAlertUpdateThreadPressed,
  });

  final void Function(String alertId, String subscriptionId) onAlertPressed;
  final void Function() onAlertUpdateThreadPressed;

  @override
  ConsumerState<AlertArchiveView> createState() => _AlertArchiveViewState();
}

class _AlertArchiveViewState extends ConsumerState<AlertArchiveView> {
  late AlertArchive alertArchive;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(alertArchiveCleanupProvider);

    var localization = context.localizations;
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.alert_archive_view_title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(localization.alert_archive_view_subtitle),
              FutureBuilder<AlertArchive>(
                future: AlertArchive.create(ref),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      alertArchive = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Divider(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    snapshot.data!.deleteArchive();
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
                            alertArchive.alertArchive.isEmpty
                                ? Text(localization.alert_archive_no_alert)
                                : const SizedBox(),
                            ...alertArchive.alertArchive.map(
                              (alert) => WarningWidget(
                                warnMessage: alert,
                                isMyPlaceWarning: false,
                                onAlertPressed: widget.onAlertPressed,
                                onAlertUpdateThreadPressed:
                                    widget.onAlertUpdateThreadPressed,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      debugPrint(
                        "Error loading alert archive: ${snapshot.error}",
                      );
                      return const Text(
                        "Error while loading alert archive, sorry.",
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
      ),
    );
  }
}
