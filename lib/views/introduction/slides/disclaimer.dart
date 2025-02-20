import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/views/introduction/widgets/base_slide.dart';
import 'package:foss_warn/widgets/dialogs/disclaimer_dialog.dart';
import 'package:foss_warn/widgets/dialogs/privacy_dialog.dart';

class IntroductionDisclaimerSlide extends StatelessWidget {
  const IntroductionDisclaimerSlide({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var theme = Theme.of(context);

    void onShowDisclaimerPressed() {
      showDialog(
        context: context,
        builder: (BuildContext context) => DisclaimerDialog(),
      );
    }

    void onShowPrivacyPressed() {
      showDialog(
        context: context,
        builder: (BuildContext context) => PrivacyDialog(),
      );
    }

    return IntroductionBaseSlide(
      imagePath: "assets/paragraph.png",
      title: localizations.welcome_view_important_headline,
      text: localizations.welcome_view_important_text,
      footer: Column(
        children: [
          TextButton(
            onPressed: onShowDisclaimerPressed,
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
            ),
            child: Text(
              localizations.about_disclaimer,
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
          TextButton(
            onPressed: onShowPrivacyPressed,
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
            ),
            child: Text(
              localizations.about_privacy,
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
