import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import '../../class/abstract_place.dart';
import '../../services/update_provider.dart';
import 'package:provider/provider.dart';

class DeletePlaceDialog extends StatefulWidget {
  final Place myPlace;
  const DeletePlaceDialog({super.key, required this.myPlace});

  @override
  State<DeletePlaceDialog> createState() => _DeletePlaceDialogState();
}

class _DeletePlaceDialogState extends State<DeletePlaceDialog> {
  @override
  Widget build(BuildContext context) {
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
          onPressed: () {
            //remove place from list and update view
            debugPrint("place deleted");

            // If FPAS Place, unsubscribe from server
            if (widget.myPlace is FPASPlace) {
              debugPrint(
                  "unregister from server for place ${widget.myPlace.name}");
              (widget.myPlace as FPASPlace).unregisterForArea();
            }

            final updater = Provider.of<Update>(context, listen: false);
            updater.deletePlace(widget.myPlace);
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context)!.delete_place_delete,
          ),
        )
      ],
    );
  }
}
