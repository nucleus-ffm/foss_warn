import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

class CategoryExplanation extends StatefulWidget {
  const CategoryExplanation({super.key});

  @override
  State<CategoryExplanation> createState() => _CategoryExplanationState();
}

class _CategoryExplanationState extends State<CategoryExplanation> {
  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;

    return AlertDialog(
      title: Text(localizations.explanation_headline),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(
                  text: "${localizations.explanation_health}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: localizations.explanation_health_text),
                TextSpan(text: '\n \n'),
                TextSpan(
                  text: "${localizations.explanation_fire}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: localizations.explanation_fire_text),
                TextSpan(text: '\n \n'),
                TextSpan(
                  text: "${localizations.explanation_infrastructure}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: localizations.explanation_infrastructure_text),
                TextSpan(text: '\n \n'),
                TextSpan(
                  text: "${localizations.explanation_CBRNE}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: localizations.explanation_CBRNE_text),
                TextSpan(text: '\n \n'),
                TextSpan(
                  text: "${localizations.explanation_environment}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: localizations.explanation_environment_text),
                TextSpan(text: '\n \n'),
                TextSpan(
                  text: "${localizations.explanation_weather}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: localizations.explanation_weather_text),
                TextSpan(text: '\n \n'),
                TextSpan(
                  text: "${localizations.explanation_safety}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: localizations.explanation_safety_text),
                TextSpan(text: '\n \n'),
                TextSpan(
                  text: "${localizations.explanation_other}: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: localizations.explanation_other_text),
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
          child: Text(localizations.main_dialog_close),
        ),
      ],
    );
  }
}
