import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

class MessageTypeExplanation extends StatefulWidget {
  const MessageTypeExplanation({super.key});

  @override
  State<MessageTypeExplanation> createState() => _MessageTypeExplanationState();
}

class _MessageTypeExplanationState extends State<MessageTypeExplanation> {
  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var defaultTextStyle = DefaultTextStyle.of(context);
    var navigator = Navigator.of(context);

    return AlertDialog(
      title: Text(localizations.explanation_warning_level_headline),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              style: defaultTextStyle.style,
              children: <TextSpan>[
                TextSpan(
                  text:
                      "${localizations.explanation_warning_level_attention}: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: localizations.explanation_warning_level_attention_text,
                ),
                const TextSpan(text: '\n\n'),
                TextSpan(
                  text: "${localizations.explanation_warning_level_update}: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: localizations.explanation_warning_level_update_text,
                ),
                const TextSpan(text: '\n\n'),
                TextSpan(
                  text:
                      "${localizations.explanation_warning_level_all_clear}: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: localizations.explanation_warning_level_all_clear_text,
                ),
              ],
            ),
          ),
        ],
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
