import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryExplanation extends StatefulWidget {
  const CategoryExplanation({super.key});

  @override
  State<CategoryExplanation> createState() => _CategoryExplanationState();
}

class _CategoryExplanationState extends State<CategoryExplanation> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.explanation_headline),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(
                    text:
                        "${AppLocalizations.of(context)!.explanation_health}: ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        AppLocalizations.of(context)!.explanation_health_text),
                TextSpan(text: '\n \n'),
                TextSpan(
                    text: "${AppLocalizations.of(context)!.explanation_fire}: ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: AppLocalizations.of(context)!.explanation_fire_text),
                TextSpan(text: '\n \n'),
                TextSpan(
                    text:
                        "${AppLocalizations.of(context)!.explanation_infrastructure}: ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: AppLocalizations.of(context)!
                        .explanation_infrastructure_text),
                TextSpan(text: '\n \n'),
                TextSpan(
                    text:
                        "${AppLocalizations.of(context)!.explanation_CBRNE}: ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: AppLocalizations.of(context)!.explanation_CBRNE_text),
                TextSpan(text: '\n \n'),
                TextSpan(
                    text:
                        "${AppLocalizations.of(context)!.explanation_environment}: ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: AppLocalizations.of(context)!
                        .explanation_environment_text),
                TextSpan(text: '\n \n'),
                TextSpan(
                    text:
                        "${AppLocalizations.of(context)!.explanation_weather}: ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        AppLocalizations.of(context)!.explanation_weather_text),
                TextSpan(text: '\n \n'),
                TextSpan(
                    text:
                        "${AppLocalizations.of(context)!.explanation_safety}: ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        AppLocalizations.of(context)!.explanation_safety_text),
                TextSpan(text: '\n \n'),
                TextSpan(
                    text:
                        "${AppLocalizations.of(context)!.explanation_other}: ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: AppLocalizations.of(context)!.explanation_other_text),
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
