import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/class/class_AlertSwissPlace.dart';
import 'package:foss_warn/class/class_NinaPlace.dart';
import '../../class/abstract_Place.dart';
import '../../services/updateProvider.dart';
import 'package:provider/provider.dart';

class MetaInfoForPlaceDialog extends StatefulWidget {
  final Place myPlace;
  const MetaInfoForPlaceDialog({Key? key, required this.myPlace})
      : super(key: key);

  @override
  _DeletePlaceDialogState createState() => _DeletePlaceDialogState();
}

class _DeletePlaceDialogState extends State<MetaInfoForPlaceDialog> {
  @override
  Widget build(BuildContext context) {
    NinaPlace? ninaPlace;
    AlertSwissPlace? alertSwissPlace;
    if (widget.myPlace is NinaPlace) {
      ninaPlace = widget.myPlace as NinaPlace;
    } else if (widget.myPlace is AlertSwissPlace) {
      alertSwissPlace = widget.myPlace as AlertSwissPlace;
    }

    return AlertDialog(
      title: Text(
          "Meta information for ${widget.myPlace.name}"), //@todo translate
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //Text(AppLocalizations.of(context).delete_place_confirmation),
            widget.myPlace is NinaPlace
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nina-ARS: ${ninaPlace?.geocode.geocodeNumber}"),
                      Text("Latitude: ${ninaPlace?.geocode.latitude}"),
                      Text("Longitude: ${ninaPlace?.geocode.longitude}"),
                      Text("PLZ: ${ninaPlace?.geocode.PLZ}")
                    ],
                  )
                : Text("Shortname: ${alertSwissPlace?.shortName}"),
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
