import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IntroductionCheckmark extends StatelessWidget {
  const IntroductionCheckmark({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Icon(
          Icons.check,
          size: 56,
          color: Colors.green,
        ),
        Text(
          localizations.welcome_view_action_success,
          style: TextStyle(
            color: Colors.grey,
            letterSpacing: 1.2,
            fontSize: 16.0,
            height: 1.3,
          ),
        )
      ],
    );
  }
}
