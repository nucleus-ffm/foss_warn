import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/services/api_handler.dart';
import 'package:foss_warn/services/list_handler.dart';

class DeletePlaceDialog extends ConsumerWidget {
  final Place myPlace;
  const DeletePlaceDialog({super.key, required this.myPlace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var localizations = context.localizations;
    var theme = Theme.of(context);
    var navigator = Navigator.of(context);

    var alertApi = ref.read(alertApiProvider);
    var scaffoldMessenger = ScaffoldMessenger.of(context);

    Future<void> onDeletePlacePressed() async {
      // remove place from list and update view

      // Unsubscribe from server
      debugPrint("unregister from server for place ${myPlace.name}");
      try {
        await alertApi.unregisterArea(
          subscriptionId: myPlace.subscriptionId,
        );
        ref.read(myPlacesProvider.notifier).remove(myPlace);
      } on UnregisterAreaError {
        // we currently can not unsubscribe - show a snack bar to inform the
        // user to check their internet connection
        final snackBar = SnackBar(
          content: Text(
            localizations.delete_place_error,
            style: TextStyle(color: theme.colorScheme.onErrorContainer),
          ),
          backgroundColor: theme.colorScheme.errorContainer,
        );
        scaffoldMessenger.showSnackBar(snackBar);
      }

      if (!context.mounted) return;
      navigator.pop();
    }

    return AlertDialog(
      title: Text(localizations.delete_place_headline),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(localizations.delete_place_confirmation),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () => navigator.pop(),
          child: Text(localizations.delete_place_cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: onDeletePlacePressed,
          child: Text(localizations.delete_place_delete),
        ),
      ],
    );
  }
}
