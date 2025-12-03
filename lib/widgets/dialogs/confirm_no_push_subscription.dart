import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/extensions/context.dart';

import '../../enums/alert_service.dart';

class ConfirmNoPushDialog extends ConsumerStatefulWidget {
  const ConfirmNoPushDialog({super.key});

  @override
  ConsumerState<ConfirmNoPushDialog> createState() =>
      _ConfirmNoPushDialogState();
}

class _ConfirmNoPushDialogState extends ConsumerState<ConfirmNoPushDialog> {
  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var navigator = Navigator.of(context);

    AlertService selectedService =
        ref.read(userPreferencesProvider).alertService;

    return AlertDialog(
      title: Text(localizations.confirm_no_push_subscription_headline),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (selectedService) {
              AlertService.poll =>
                Text(localizations.confirm_no_push_subscription_body_polling),
              AlertService.push =>
                Text(localizations.confirm_no_push_subscription_body_push),
              AlertService.pushAndPoll =>
                Text(localizations.confirm_no_push_subscription_body_polling),
              AlertService.nothing =>
                Text(localizations.confirm_no_push_subscription_body_nothing),
            },
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => navigator.pop(true),
          child: Text(localizations.confirmation_dialog_confirm),
        ),
        TextButton(
          onPressed: () => navigator.pop(false),
          child: Text(localizations.confirmation_dialog_cancel),
        ),
      ],
    );
  }
}
