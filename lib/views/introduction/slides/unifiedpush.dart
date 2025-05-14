import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/views/introduction/widgets/base_slide.dart';

import '../../../services/url_launcher.dart';

class IntroductionUnifiedpushSlide extends StatelessWidget {
  const IntroductionUnifiedpushSlide({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;

    return IntroductionBaseSlide(
      imagePath: "bell.png",
      title: localizations.welcome_view_unifiedpush_headline,
      text: localizations.welcome_view_unifiedpush_text,
      footer: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.open_in_browser),
              Flexible(
                fit: FlexFit.loose,
                child: TextButton(
                  onPressed: () => launchUrlInBrowser(
                    "https://github.com/nucleus-ffm/foss_warn/wiki/What-is-UnifiedPush-and-how-to-select-a-distributor",
                  ),
                  child: Text(
                    localizations.welcome_view_unifiedpush_learn_more_button,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
