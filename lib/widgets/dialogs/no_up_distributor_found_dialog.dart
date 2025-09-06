import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';
import '../../services/url_launcher.dart';

class NoUPDistributorFoundDialog extends StatefulWidget {
  const NoUPDistributorFoundDialog({super.key});

  @override
  State<NoUPDistributorFoundDialog> createState() =>
      _NoUPDistributorFoundDialogState();
}

class _NoUPDistributorFoundDialogState
    extends State<NoUPDistributorFoundDialog> {
  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var navigator = Navigator.of(context);

    return AlertDialog(
      title: Text(localizations.no_up_distributor_found_dialog_title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.no_up_distributor_found_dialog_explanation),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Icon(Icons.open_in_browser),
                Flexible(
                  fit: FlexFit.loose,
                  child: TextButton(
                    onPressed: () => launchUrlInBrowser(
                      'https://github.com/nucleus-ffm/foss_warn/wiki/What-is-UnifiedPush-and-how-to-select-a-distributor',
                    ),
                    child: Text(
                      localizations
                          .no_up_distributor_found_up_explanation_button,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.open_in_browser),
                Flexible(
                  fit: FlexFit.loose,
                  child: TextButton(
                    onPressed: () => launchUrlInBrowser(
                      'https://f-droid.org/de/packages/io.heckel.ntfy/',
                    ),
                    child: Text(
                      localizations.no_up_distributor_found_direct_link_to_ntfy,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => navigator.pop(),
          child: Text(localizations.main_dialog_understand),
        ),
      ],
    );
  }
}
