import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/views/introduction/widgets/base_slide.dart';

import 'package:foss_warn/services/url_launcher.dart';

class IntroductionFPASServerInfoSlide extends StatelessWidget {
  const IntroductionFPASServerInfoSlide({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    const fpasServerExplanationURL =
        'https://github.com/nucleus-ffm/foss_warn/wiki/What-is-the-FOSS-Public-Alert-Server-and-why-do-I-have-to-select-a-server%3F';

    return IntroductionBaseSlide(
      imagePath: "app_icon.png",
      title: localizations.welcome_view_foss_server_selection_headline,
      text: localizations.welcome_view_foss_server_selection_text,
      footer: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.open_in_browser),
              Flexible(
                fit: FlexFit.loose,
                child: TextButton(
                  onPressed: () => launchUrlInBrowser(fpasServerExplanationURL),
                  child: Text(
                    localizations
                        .welcome_view_foss_server_selection_select_instance_helptext,
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
