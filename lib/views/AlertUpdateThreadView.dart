import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_WarnMessage.dart';

import '../widgets/WarningWidget.dart';

class AlertUpdateThreadView extends StatefulWidget {
  final WarnMessage latestAlert;
  final List<WarnMessage> previousNowUpdatedAlerts;
  AlertUpdateThreadView({super.key, required this.latestAlert, required this.previousNowUpdatedAlerts});

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
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("latest version of the alert"),
              WarningWidget(warnMessage: widget.latestAlert),
              SizedBox(height: 10,),
              Text("previous updates of this alert"),
              SizedBox(height: 10,),
              ...widget.previousNowUpdatedAlerts.map((_element)
              => WarningWidget(warnMessage: _element,)).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
