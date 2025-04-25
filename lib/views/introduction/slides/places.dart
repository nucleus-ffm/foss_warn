import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/views/introduction/widgets/base_slide.dart';

class IntroductionPlacesSlide extends StatelessWidget {
  const IntroductionPlacesSlide({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;

    return IntroductionBaseSlide(
      imagePath: "location.png",
      title: localizations.welcome_view_my_places_headline,
      text: localizations.welcome_view_my_places_text,
    );
  }
}
