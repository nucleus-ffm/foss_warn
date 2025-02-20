import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_warn_message.dart';

import '../widgets/warning_widget.dart';

class AlertUpdateThreadView extends StatefulWidget {
  final WarnMessage latestAlert;
  final List<WarnMessage> previousNowUpdatedAlerts;
  const AlertUpdateThreadView({
    super.key,
    required this.latestAlert,
    required this.previousNowUpdatedAlerts,
  });

  @override
  State<AlertUpdateThreadView> createState() => _AlertUpdateThreadViewState();
}

class _AlertUpdateThreadViewState extends State<AlertUpdateThreadView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update thread for ${widget.latestAlert.identifier}"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text("latest version of the alert"),
            WarningWidget(
              warnMessage: widget.latestAlert,
              isMyPlaceWarning: true,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text("previous updates of this alert"),
            const SizedBox(
              height: 10,
            ),
            ...widget.previousNowUpdatedAlerts.map(
              (element) => WarningWidget(
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
