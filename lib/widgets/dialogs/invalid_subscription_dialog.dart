import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/services/api_handler.dart';

import '../../class/class_fpas_place.dart';
import '../../services/alert_api/fpas.dart';
import '../../services/list_handler.dart';
import 'loading_screen.dart';

enum State { readyToResubscribe, successfullyResubscribed, error }

class InvalidSubscriptionDialog extends ConsumerStatefulWidget {
  const InvalidSubscriptionDialog({super.key});

  @override
  InvalidSubscriptionDialogState createState() =>
      InvalidSubscriptionDialogState();
}

class InvalidSubscriptionDialogState
    extends ConsumerState<InvalidSubscriptionDialog> {
  RegisterAreaError? failedToResubscribe;
  State currentState = State.readyToResubscribe;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var userPreferences = ref.watch(userPreferencesProvider);
    var places = ref.read(myPlacesProvider);

    // replace every placed that is flagged as isExpired
    Future<void> onReSubscribe() async {
      if (!context.mounted) return;
      LoadingScreen.instance().show(
        context: context,
        text: localizations.loading_screen_loading,
      );
      var alertApi = ref.read(alertApiProvider);

      if (!context.mounted) return;
      LoadingScreen.instance().show(
        context: context,
        text: localizations
            .invalid_subscription_dialog_loading_indicator_replace_places,
      );

      for (Place place in places) {
        if (!place.isExpired) {
          continue;
        }
        String newSubscriptionId = "";
        // register again
        try {
          newSubscriptionId = await alertApi.registerArea(
            boundingBox: place.boundingBox,
            unifiedPushEndpoint: userPreferences.unifiedPushEndpoint,
          );
        } on RegisterAreaError catch (e) {
          setState(() {
            currentState = State.error;
            failedToResubscribe = e;
          });
          LoadingScreen.instance().hide();
          return;
        }
        // replace the old subscription id with the new one
        ref.read(myPlacesProvider.notifier).set(
              ref.read(myPlacesProvider).updateEntry(
                    place.copyWith(
                      subscriptionId: newSubscriptionId,
                      isExpired: false,
                    ),
                  ),
            );
      }
      setState(() {
        currentState = State.successfullyResubscribed;
      });

      LoadingScreen.instance().hide();
    }

    Widget body = _ReadyToResubscribe(onReSubscribe: onReSubscribe);

    switch (currentState) {
      case State.readyToResubscribe:
        body = _ReadyToResubscribe(onReSubscribe: onReSubscribe);
        break;
      case State.error:
        body = _FailedToResubscribe(
          failedToResubscribe: failedToResubscribe!,
          onReSubscribe: onReSubscribe,
        );
        break;
      case State.successfullyResubscribed:
        body = const _SuccessfullyResubscribed();
        break;
    }

    return AlertDialog(
      title: Text(localizations.invalid_subscription_dialog_headline),
      content: body,
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            localizations.main_dialog_close,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      ],
    );
  }
}

class _ReadyToResubscribe extends StatelessWidget {
  const _ReadyToResubscribe({required this.onReSubscribe});

  final VoidCallback onReSubscribe;

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    ThemeData theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          localizations.invalid_subscription_dialog_text,
        ),
        const SizedBox(height: 10),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
          ),
          onPressed: onReSubscribe,
          child: Text(
            localizations.invalid_subscription_dialog_resubscribe_button,
            style: TextStyle(
              color: theme.colorScheme.onSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _FailedToResubscribe extends StatelessWidget {
  const _FailedToResubscribe({
    required this.failedToResubscribe,
    required this.onReSubscribe,
  });
  final RegisterAreaError failedToResubscribe;
  final VoidCallback onReSubscribe;

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    ThemeData theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          localizations.invalid_subscription_dialog_error_body,
          style: const TextStyle(fontSize: 18),
        ),
        Text(
          localizations.invalid_subscription_dialog_error_status_code(
            failedToResubscribe.statusCode.toString(),
          ),
        ),
        Text(
          localizations.invalid_subscription_dialog_error_message(
            failedToResubscribe.message,
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
          ),
          onPressed: onReSubscribe,
          child: Text(
            localizations.invalid_subscription_dialog_resubscribe_button,
            style: TextStyle(
              color: theme.colorScheme.onSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessfullyResubscribed extends StatelessWidget {
  const _SuccessfullyResubscribed();

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 150,
          color: theme.colorScheme.secondary,
        ),
        Text(
          localizations.invalid_subscription_dialog_successfully_resubscribed,
        ),
      ],
    );
  }
}
