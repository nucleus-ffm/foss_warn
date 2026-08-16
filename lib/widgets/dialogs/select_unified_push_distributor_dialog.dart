import 'package:flutter/material.dart';

import '../../extensions/context.dart';
import '../../services/url_launcher.dart';

Widget Function(BuildContext) selectUnifiedPushDistributorDialog(
  List<String> distributors,
) {
  return (BuildContext context) {
    var localizations = context.localizations;
    return SimpleDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(localizations.select_unified_push_distributor_title),
          ),
          IconButton(
            onPressed: () => launchUrlInBrowser(
              'https://docs.fosswarn.org/features/push_services/#select-your-push-service',
            ),
            icon: const Icon(Icons.help),
            tooltip: localizations.alert_service_dialog_help_text,
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            localizations.select_unified_push_distributor_subtitle,
          ),
        ),
        ...distributors.map<Widget>(
          (d) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, d);
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(d),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  };
}
