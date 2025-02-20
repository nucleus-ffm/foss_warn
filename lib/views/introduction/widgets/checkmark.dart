import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

class IntroductionCheckmark extends StatelessWidget {
  const IntroductionCheckmark({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;

    return Column(
      children: [
        const Icon(
          Icons.check,
          size: 56,
          color: Colors.green,
        ),
        Text(
          localizations.welcome_view_action_success,
          style: const TextStyle(
            color: Colors.grey,
            letterSpacing: 1.2,
            fontSize: 16.0,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
