import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import '../../services/update_provider.dart';

class DeletePlaceDialog extends ConsumerWidget {
  final Place myPlace;
  const DeletePlaceDialog({super.key, required this.myPlace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var updater = ref.read(updaterProvider);
    var alertApi = ref.read(alertApiProvider);

    Future<void> onDeletePlacePressed() async {
      //remove place from list and update view
      debugPrint("place deleted");

      // Unsubscribe from server
      debugPrint("unregister from server for place ${myPlace.name}");
      await alertApi.unregisterArea(
        subscriptionId: myPlace.subscriptionId,
      );

      updater.deletePlace(myPlace);

      if (!context.mounted) return;
      Navigator.of(context).pop();
    }

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.delete_place_headline),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppLocalizations.of(context)!.delete_place_confirmation),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.delete_place_cancel)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError),
          onPressed: onDeletePlacePressed,
          child: Text(
            AppLocalizations.of(context)!.delete_place_delete,
          ),
        )
      ],
    );
  }
}
