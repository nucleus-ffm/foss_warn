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
      title: const Text("No push distributor found"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(//@todo translation
                "FOSSWarn couldn't find any UnifiedPush distributor installed"
                " on your device. To subscribe to an area, you must have one"
                " installed, or you won't get any notification."
                " Please install a distributor and retry the subscription."),
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
                    child: const Text(
                      //@todo translation
                      "What is unifiedPush and how to install a distributor?",
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
                    child: const Text("For the fast ones: ntfy on F-Droid"),
                  ), //@todo translation
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
