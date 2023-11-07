import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../class/abstract_Place.dart';
import '../../services/updateProvider.dart';
import 'package:provider/provider.dart';

class DeletePlaceDialog extends StatefulWidget {
  final Place myPlace;
  const DeletePlaceDialog({Key? key, required this.myPlace}) : super(key: key);

  @override
  _DeletePlaceDialogState createState() => _DeletePlaceDialogState();
}

class _DeletePlaceDialogState extends State<DeletePlaceDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.delete_place_headline),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.delete_place_confirmation),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context)!.delete_place_cancel,
            style: TextStyle(color: Colors.red),
          ),
        ),
        new TextButton(
          onPressed: () {
            //remove place from list and update view
            print("place deleted");
            final updater = Provider.of<Update>(context, listen: false);
            updater.deletePlace(widget.myPlace);
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context)!.delete_place_delete,
            style: TextStyle(color: Colors.green),
          ),
        )
      ],
    );
  }
}
