import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/class/class_AlertSwissPlace.dart';
import 'package:foss_warn/class/class_FPASPlace.dart';
import 'package:foss_warn/class/class_NinaPlace.dart';
import '../../class/abstract_Place.dart';

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
    FPASPlace? fpasPlace;
    if (widget.myPlace is NinaPlace) {
      ninaPlace = widget.myPlace as NinaPlace;
    } else if (widget.myPlace is AlertSwissPlace) {
      alertSwissPlace = widget.myPlace as AlertSwissPlace;
    } else if (widget.myPlace is FPASPlace ){
      fpasPlace = widget.myPlace as FPASPlace;
    }


    List<Text> generateMetaInfo(Place place) {
      if (place is NinaPlace) {
        return [
          Text("Nina-ARS: ${ninaPlace?.geocode.geocodeNumber}"),
          Text("Latitude: ${ninaPlace?.geocode.latLng.latitude}"),
          Text("Longitude: ${ninaPlace?.geocode.latLng.longitude}"),
          Text("PLZ: ${ninaPlace?.geocode.PLZ}")];
      } else if (place is AlertSwissPlace) {
        return [Text("Shortname: ${alertSwissPlace?.shortName}")];
      } else if (place is FPASPlace) {
        return [
          Text("Bounding box max: \n\t\tLng: ${fpasPlace!.boundingBox.max_latLng.longitude}  \n\t\tLat: ${fpasPlace!.boundingBox.max_latLng.latitude}"),
          Text("\n"),
          Text("Bounding box min:\n\t\t Lng: ${fpasPlace.boundingBox.min_latLng.longitude} \n\t\t Lat: ${fpasPlace.boundingBox.min_latLng.latitude}"),
          Text("\n"),
          Text("SubscriptionID: ${fpasPlace.subscriptionId}"),
        ];
      } else {
        return [];
      }
    }

    return AlertDialog(
      title: Text(
          "Meta information for ${widget.myPlace.name}"), //@todo translate
      content: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: generateMetaInfo(widget.myPlace)
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.main_dialog_close)),
      ],
    );
  }
}
