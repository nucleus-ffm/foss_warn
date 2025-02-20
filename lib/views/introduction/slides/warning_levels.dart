import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/views/introduction/widgets/base_slide.dart';

class IntroductionWarningLevelsSlide extends StatelessWidget {
  const IntroductionWarningLevelsSlide({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;

    return IntroductionBaseSlide(
      imagePath: "assets/steps.png",
      title: localizations.welcome_view_warning_steps_headline,
      text: localizations.welcome_view_warning_steps_text,
    );
  }
}
