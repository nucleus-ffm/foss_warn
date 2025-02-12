import 'package:flutter/material.dart';
import 'package:foss_warn/views/introduction/widgets/base_slide.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IntroductionWelcomeSlide extends StatelessWidget {
  const IntroductionWelcomeSlide({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;

    return IntroductionBaseSlide(
      imagePath: "assets/app_icon/app_icon.png",
      title: localizations.welcome_view_foss_warn_headline,
      text: localizations.welcome_view_foss_warn_text,
    );
  }
}
