import 'package:flutter/material.dart';
import '../MyPlacesView.dart';
import '../class/class_Place.dart';
import '../services/updateProvider.dart';
import 'package:provider/provider.dart';

class DeletePlaceDialog extends StatefulWidget {
  final Place myPlace;
  const DeletePlaceDialog({Key? key, required this.myPlace}) : super(key: key);

  @override
  _DeletePlaceDialogState createState() => _DeletePlaceDialogState();
}

class _DeletePlaceDialogState extends State<DeletePlaceDialog> {
  String newPlaceName = "";
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ort löschen?'),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Bist Du sicher, dass Du diesen Ort löschen möchtest?"),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Abbrechen', style: TextStyle(color: Colors.red),),
        ),
        new TextButton(
          onPressed: () {
            //remove place from list and update view
            print("place deleted");
            final updater =
            Provider.of<Update>(context, listen: false);
            updater.deletePlace(widget.myPlace);
            Navigator.of(context).pop();
          },
          child: Text('Löschen', style: TextStyle(color: Colors.green),),
        )
      ],
      backgroundColor: Colors.white,
    );
  }
}
