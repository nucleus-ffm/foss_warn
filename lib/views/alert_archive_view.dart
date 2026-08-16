import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_alert_archive.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/widgets/warning_widget.dart';

import '../services/url_launcher.dart';

final alertArchiveProvider = FutureProvider<AlertArchive>((ref) async {
  return await AlertArchive.create(ref);
});

class AlertArchiveView extends ConsumerWidget {
  const AlertArchiveView({
    super.key,
    required this.onAlertPressed,
    required this.onAlertUpdateThreadPressed,
  });

  final void Function(String alertId, String subscriptionId) onAlertPressed;
  final void Function() onAlertUpdateThreadPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var localization = context.localizations;

    final archiveAsync = ref.watch(alertArchiveProvider);
    ref.watch(alertArchiveCleanupProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.alert_archive_view_title),
        actions: [
          if (archiveAsync.hasValue)
            IconButton(
              icon: const Icon(
                Icons.delete,
                semanticLabel: "Delete alert archive",
              ),
              tooltip: localization.error_log_button_delete,
              onPressed: () async {
                await archiveAsync.value!.deleteArchive();
                ref.invalidate(alertArchiveProvider);
              },
            ),
          IconButton(
            onPressed: () => launchUrlInBrowser(
              'https://docs.fosswarn.org/features/alert_archive/',
            ),
            icon: const Icon(Icons.help),
            tooltip: localization.help_tooltip,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(localization.alert_archive_view_subtitle),

              // Use .when to handle Loading, Error, and Data states cleanly
              archiveAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text(
                  "Error while loading alert archive, sorry.",
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                data: (alertArchive) {
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
                        alertArchive.alertArchive.isEmpty
                            ? Text(localization.alert_archive_no_alert)
                            : const SizedBox(),
                        ...alertArchive.alertArchive.map(
                          (alert) => WarningWidget(
                            warnMessage: alert,
                            isMyPlaceWarning: false,
                            onAlertPressed: onAlertPressed,
                            onAlertUpdateThreadPressed:
                                onAlertUpdateThreadPressed,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
