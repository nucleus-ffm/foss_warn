import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

class MissingImprintDialog extends StatefulWidget {
  const MissingImprintDialog({super.key});

  @override
  State<MissingImprintDialog> createState() => _MissingImprintDialogState();
}

class _MissingImprintDialogState extends State<MissingImprintDialog> {
  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var navigator = Navigator.of(context);

    return AlertDialog(
      title: Text(localizations.imprint_headline),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.imprint_main_text),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => navigator.pop(),
          child: Text(localizations.main_dialog_close),
        ),
      ],
    );
  }
}
