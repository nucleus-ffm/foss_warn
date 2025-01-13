import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WarningSourcesDialog extends StatefulWidget {
  const WarningSourcesDialog({super.key});

  @override
  State<WarningSourcesDialog> createState() => _WarningSourcesDialog();
}

class _WarningSourcesDialog extends State<WarningSourcesDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.source_headline),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        child: ListView(
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context)!.source_mowas_title),
              subtitle: Text(
                AppLocalizations.of(context)!.source_mowas_description,
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.source_biwapp_title),
              subtitle: Text(
                AppLocalizations.of(context)!.source_biwapp_description,
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.source_katwarn_title),
              subtitle: Text(
                AppLocalizations.of(context)!.source_katwarn_description,
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.source_dwd_title),
              subtitle:
                  Text(AppLocalizations.of(context)!.source_dwd_description),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.source_lhp_title),
              subtitle:
                  Text(AppLocalizations.of(context)!.source_lhp_description),
            ),
            ListTile(
              title:
                  Text(AppLocalizations.of(context)!.source_alertswiss_title),
              subtitle: Text(
                AppLocalizations.of(context)!.source_alertswiss_description,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.main_dialog_close),
        ),
      ],
    );
  }
}
