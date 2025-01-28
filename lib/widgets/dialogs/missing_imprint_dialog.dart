import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MissingImprintDialog extends StatefulWidget {
  const MissingImprintDialog({super.key});

  @override
  State<MissingImprintDialog> createState() => _MissingImprintDialogState();
}

class _MissingImprintDialogState extends State<MissingImprintDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.imprint_headline),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.imprint_main_text),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.main_dialog_close),
        ),
      ],
    );
  }
}
