import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/views/introduction/widgets/base_slide.dart';

class IntroductionWarningLevelsSlide extends StatelessWidget {
  const IntroductionWarningLevelsSlide({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;

    return IntroductionBaseSlide(
      imagePath: "assets/steps.png",
      title: localizations.welcome_view_warning_steps_headline,
      text: localizations.welcome_view_warning_steps_text,
    );
  }
}
