import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WarningSeverityExplanation extends StatefulWidget {
  const WarningSeverityExplanation({super.key});

  @override
  State<WarningSeverityExplanation> createState() =>
      _WarningSeverityExplanationState();
}

class _WarningSeverityExplanationState
    extends State<WarningSeverityExplanation> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!
          .warning_severity_explanation_dialog_headline),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              text: '',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium, //DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(
                    text: AppLocalizations.of(context)!
                        .notification_settings_slidervalue_extreme,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '\n'),
                TextSpan(
                    text: //warning_severity_explanation_dialog_extreme_description
                        AppLocalizations.of(context)!
                            .warning_severity_explanation_dialog_extreme_description),
                TextSpan(text: '\n\n'),
                TextSpan(
                    text: AppLocalizations.of(context)!
                        .notification_settings_slidervalue_severe,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '\n'),
                TextSpan(
                    text: //warning_severity_explanation_dialog_severe_description
                        AppLocalizations.of(context)!
                            .warning_severity_explanation_dialog_severe_description),
                TextSpan(text: '\n\n'),
                TextSpan(
                    text: AppLocalizations.of(context)!
                        .notification_settings_slidervalue_moderate,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '\n'),
                TextSpan(
                    text: //warning_severity_explanation_dialog_moderate_description
                        AppLocalizations.of(context)!
                            .warning_severity_explanation_dialog_moderate_description),
                TextSpan(text: '\n\n'),
                TextSpan(
                    text: AppLocalizations.of(context)!
                        .notification_settings_slidervalue_minor,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '\n'),
                TextSpan(
                    text: //warning_severity_explanation_dialog_minor_description
                        AppLocalizations.of(context)!
                            .warning_severity_explanation_dialog_minor_description),
              ],
            ),
          ),
        ],
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
