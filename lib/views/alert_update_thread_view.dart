import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/extensions/context.dart';

import '../widgets/warning_widget.dart';

final alertUpdateThreadViewModelProvider =
    StateProvider<AlertUpdateThreadViewModel?>((ref) => null);

class AlertUpdateThreadViewModel {
  final WarnMessage latestAlert;
  final List<WarnMessage> previousNowUpdatedAlerts;

  const AlertUpdateThreadViewModel({
    required this.latestAlert,
    required this.previousNowUpdatedAlerts,
  });
}

class AlertUpdateThreadView extends ConsumerStatefulWidget {
  const AlertUpdateThreadView({
    required this.onAlertPressed,
    required this.onAlertUpdateThreadPressed,
    super.key,
  });

  final void Function(String fpasAlertId, String subscriptionId) onAlertPressed;
  final void Function() onAlertUpdateThreadPressed;

  @override
  ConsumerState<AlertUpdateThreadView> createState() =>
      _AlertUpdateThreadViewState();
}

class _AlertUpdateThreadViewState extends ConsumerState<AlertUpdateThreadView> {
  @override
  Widget build(BuildContext context) {
    var localization = context.localizations;
    var alertUpdateThreadViewModel =
        ref.read(alertUpdateThreadViewModelProvider);
    if (alertUpdateThreadViewModel == null) {
      return const Text("Error - no alert update thread found");
    }
    var latestAlert = alertUpdateThreadViewModel.latestAlert;
    var previousNowUpdatedAlerts =
        alertUpdateThreadViewModel.previousNowUpdatedAlerts;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localization.alert_update_thread_title(latestAlert.identifier),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(localization.alert_update_thread_latest_version),
            WarningWidget(
              onAlertPressed: widget.onAlertPressed,
              onAlertUpdateThreadPressed: widget.onAlertUpdateThreadPressed,
              warnMessage: latestAlert,
              isMyPlaceWarning: true,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(localization.alert_update_thread_previous_updates),
            const SizedBox(
              height: 10,
            ),
            ...previousNowUpdatedAlerts.map(
              (element) => WarningWidget(
                onAlertPressed: widget.onAlertPressed,
                onAlertUpdateThreadPressed: widget.onAlertUpdateThreadPressed,
                warnMessage: element,
                isMyPlaceWarning: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
