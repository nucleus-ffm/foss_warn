import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

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
    var localizations = context.localizations;
    var theme = Theme.of(context);
    var navigator = Navigator.of(context);

    return AlertDialog(
      title: Text(localizations.warning_severity_explanation_dialog_headline),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              text: '',
              style: theme.textTheme.bodyMedium,
              children: <TextSpan>[
                TextSpan(
                  text: localizations.notification_settings_slidervalue_extreme,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '\n'),
                TextSpan(
                  text: localizations
                      .warning_severity_explanation_dialog_extreme_description,
                ),
                TextSpan(text: '\n\n'),
                TextSpan(
                  text: localizations.notification_settings_slidervalue_severe,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '\n'),
                TextSpan(
                  text: localizations
                      .warning_severity_explanation_dialog_severe_description,
                ),
                TextSpan(text: '\n\n'),
                TextSpan(
                  text:
                      localizations.notification_settings_slidervalue_moderate,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '\n'),
                TextSpan(
                  text: localizations
                      .warning_severity_explanation_dialog_moderate_description,
                ),
                TextSpan(text: '\n\n'),
                TextSpan(
                  text: localizations.notification_settings_slidervalue_minor,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '\n'),
                TextSpan(
                  text: localizations
                      .warning_severity_explanation_dialog_minor_description,
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
