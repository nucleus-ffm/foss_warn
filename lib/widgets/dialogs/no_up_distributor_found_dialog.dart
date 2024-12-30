import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    return AlertDialog(
      title: Text("No push distributor found"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(//@todo translation
                "FOSSWarn couldn't find any UnifiedPush distributor installed"
                " on your device. To subscribe to an area, you must have one"
                " installed, or you won't get any notification."
                " Please install a distributor and retry the subscription."),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(Icons.open_in_browser),
                Flexible(
                  fit: FlexFit.loose,
                  child: TextButton(
                      onPressed: () => launchUrlInBrowser(
                          'https://github.com/nucleus-ffm/foss_warn/wiki/What-is-UnifiedPush-and-how-to-select-a-distributor'),
                      child: Text(//@todo translation
                          "What is unifiedPush and how to install a distributor?")),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.open_in_browser),
                Flexible(
                  fit: FlexFit.loose,
                  child: TextButton(
                      onPressed: () => launchUrlInBrowser(
                          'https://f-droid.org/de/packages/io.heckel.ntfy/'),
                      child: Text(
                          "For the fast ones: ntfy on F-Droid")), //@todo translation
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context)!.main_dialog_understand,
          ),
        ),
      ],
    );
  }
}
