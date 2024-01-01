import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WarningSeverityExplanation extends StatefulWidget {
  const WarningSeverityExplanation({Key? key}) : super(key: key);

  @override
  _WarningSeverityExplanationState createState() => _WarningSeverityExplanationState();
}

class _WarningSeverityExplanationState extends State<WarningSeverityExplanation> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
      Text("Schweregrade"), //warning _severity_explanation_dialog_headline
      content: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                text: '',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium, //DefaultTextStyle.of(context).style,
                children: const <TextSpan>[
                  TextSpan(
                      text: 'Extrem:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '\n'),
                  TextSpan(
                      text: //warning_severity_explanation_dialog_extreme_description
                      'Außerordentliche Bedrohung für Leben oder Eigentum. Kann sich kurzfristig signifikant auf ihre Gesundheit, ihr Eigentum und/oder öffentliche Infrastruktur auswirken.'),
                  TextSpan(text: '\n\n'),
                  TextSpan(
                      text: 'Schwer:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '\n'),
                  TextSpan(
                      text: //warning_severity_explanation_dialog_severe_description
                      'Erhebliche Bedrohung für Leben oder Eigentum. Kann ihre Gesundheit, ihr Eigentum und/oder öffentliche Infrastruktur beeinträchtigen.'),
                  TextSpan(text: '\n\n'),
                  TextSpan(
                      text: 'Moderat:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '\n'),
                  TextSpan(
                      text: //warning_severity_explanation_dialog_moderate_description
                      'Eine Warnung vor einer möglichen Bedrohung von Leben oder Eigentum. Kann den normeln Tagesablauf stark beeinträchtigen.'),
                  TextSpan(text: '\n\n'),
                  TextSpan(
                      text: 'Gering:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '\n'),
                  TextSpan(
                      text: //warning_severity_explanation_dialog_minor_description
                      'Minimale bis keine bekannte Bedrohung für Leben oder Eigentum. Kann den normalen Tagesablauf beeinträchtigen.'),
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
          child: Text(AppLocalizations.of(context)!.main_dialog_close),
        ),
      ],
    );
  }
}
