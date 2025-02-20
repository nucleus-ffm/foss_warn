import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/views/introduction/widgets/base_slide.dart';

class IntroductionFinishsSlide extends StatelessWidget {
  const IntroductionFinishsSlide({
    required this.onFinishPressed,
    super.key,
  });

  final VoidCallback onFinishPressed;

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var theme = Theme.of(context);

    return IntroductionBaseSlide(
      imagePath: "assets/check.png",
      title: localizations.welcome_view_lets_go_headline,
      text: localizations.welcome_view_lets_go_text,
      footer: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 70.0),
          child: TextButton(
            onPressed: onFinishPressed,
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
            ),
            child: Text(
              localizations.welcome_view_end_button,
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
