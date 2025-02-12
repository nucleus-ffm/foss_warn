import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/views/introduction/widgets/base_slide.dart';

class IntroductionPlacesSlide extends StatelessWidget {
  const IntroductionPlacesSlide({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;

    return IntroductionBaseSlide(
      imagePath: "assets/location.png",
      title: localizations.welcome_view_my_places_headline,
      text: localizations.welcome_view_my_places_text,
    );
  }
}
