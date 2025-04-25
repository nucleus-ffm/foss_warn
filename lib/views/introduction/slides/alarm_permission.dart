import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/views/introduction/widgets/base_slide.dart';
import 'package:foss_warn/views/introduction/widgets/checkmark.dart';

class IntroductionAlarmPermissionSlide extends StatelessWidget {
  const IntroductionAlarmPermissionSlide({
    required this.hasPermission,
    required this.onPermissionChanged,
    super.key,
  });

  final bool hasPermission;
  final VoidCallback onPermissionChanged;

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var theme = Theme.of(context);

    return IntroductionBaseSlide(
      imagePath: "permission.png",
      title: localizations.welcome_view_alarm_permission_headline,
      text: localizations.welcome_view_alarm_permission_text,
      footer: Column(
        children: [
          if (hasPermission) ...[
            const IntroductionCheckmark(),
          ] else ...[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
              ),
              onPressed: onPermissionChanged,
              child: Text(
                localizations.welcome_view_permission_action,
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
