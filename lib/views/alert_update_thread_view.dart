import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_warn_message.dart';

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
    var alertUpdateThreadViewModel =
        ref.read(alertUpdateThreadViewModelProvider)!;
    var latestAlert = alertUpdateThreadViewModel.latestAlert;
    var previousNowUpdatedAlerts =
        alertUpdateThreadViewModel.previousNowUpdatedAlerts;

    return Scaffold(
      appBar: AppBar(
        title: Text("Update thread for ${latestAlert.identifier}"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text("latest version of the alert"),
            WarningWidget(
              onAlertPressed: widget.onAlertPressed,
              onAlertUpdateThreadPressed: widget.onAlertUpdateThreadPressed,
              warnMessage: latestAlert,
              isMyPlaceWarning: true,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text("previous updates of this alert"),
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
