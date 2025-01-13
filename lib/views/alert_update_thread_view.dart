import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_warn_message.dart';

import '../widgets/warning_widget.dart';

class AlertUpdateThreadView extends StatefulWidget {
  final WarnMessage latestAlert;
  final List<WarnMessage> previousNowUpdatedAlerts;
  const AlertUpdateThreadView(
      {super.key,
      required this.latestAlert,
      required this.previousNowUpdatedAlerts});

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
            Text("latest version of the alert"),
            WarningWidget(
                warnMessage: widget.latestAlert, isMyPlaceWarning: true),
            SizedBox(
              height: 10,
            ),
            Text("previous updates of this alert"),
            SizedBox(
              height: 10,
            ),
            ...widget.previousNowUpdatedAlerts.map((element) => WarningWidget(
                  warnMessage: element,
                  isMyPlaceWarning: true,
                )),
          ],
        ),
      ),
    );
  }
}
