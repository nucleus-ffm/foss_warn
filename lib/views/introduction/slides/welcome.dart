import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/views/introduction/widgets/base_slide.dart';

class IntroductionWelcomeSlide extends StatelessWidget {
  const IntroductionWelcomeSlide({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;

    return IntroductionBaseSlide(
      imagePath: "app_icon.png",
      title: localizations.welcome_view_foss_warn_headline,
      text: localizations.welcome_view_foss_warn_text,
    );
  }
}
