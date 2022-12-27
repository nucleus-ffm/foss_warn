import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MessageTypeExplanation extends StatefulWidget {
  const MessageTypeExplanation({Key? key}) : super(key: key);

  @override
  _MessageTypeExplanationState createState() => _MessageTypeExplanationState();
}

class _MessageTypeExplanationState extends State<MessageTypeExplanation> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(AppLocalizations.of(context).explanation_warning_level_headline),
      content: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                      text: AppLocalizations.of(context)
                          .explanation_warning_level_attention,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: AppLocalizations.of(context)
                          .explanation_warning_level_attention_text),
                  TextSpan(text: '\n\n'),
                  TextSpan(
                      text: AppLocalizations.of(context)
                          .explanation_warning_level_update,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: AppLocalizations.of(context)
                          .explanation_warning_level_update_text),
                  TextSpan(text: '\n\n'),
                  TextSpan(
                      text: AppLocalizations.of(context)
                          .explanation_warning_level_all_clear,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: AppLocalizations.of(context)
                          .explanation_warning_level_all_clear_text),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context).main_dialog_close,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        ),
      ],
    );
  }
}
