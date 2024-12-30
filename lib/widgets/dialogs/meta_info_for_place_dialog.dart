import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/class/class_alert_swiss_place.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/class/class_nina_place.dart';
import '../../class/abstract_place.dart';

class MetaInfoForPlaceDialog extends StatefulWidget {
  final Place myPlace;
  const MetaInfoForPlaceDialog({super.key, required this.myPlace});

  @override
  State<MetaInfoForPlaceDialog> createState() => _DeletePlaceDialogState();
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
    } else if (widget.myPlace is FPASPlace) {
      fpasPlace = widget.myPlace as FPASPlace;
    }

    List<Text> generateMetaInfo(Place place) {
      if (place is NinaPlace) {
        return [
          Text("Nina-ARS: ${ninaPlace?.geocode.geocodeNumber}"),
          Text(
              "Latitude: ${ninaPlace?.geocode.latLng.latitude}"), // meta_info_for_place_dialog_latitude
          Text(
              "Longitude: ${ninaPlace?.geocode.latLng.longitude}"), // meta_info_for_place_dialog_longitude
          Text("PLZ: ${ninaPlace?.geocode.plz}")
        ];
      } else if (place is AlertSwissPlace) {
        return [Text("Shortname: ${alertSwissPlace?.shortName}")];
      } else if (place is FPASPlace) {
        return [
          Text(
              "Bounding box max: \n\t\tLng: ${fpasPlace!.boundingBox.maxLatLng.longitude}  \n\t\tLat: ${fpasPlace.boundingBox.maxLatLng.latitude}"), // meta_info_for_place_dialog_bounding_box_max
          Text("\n"),
          Text(
              "Bounding box min:\n\t\t Lng: ${fpasPlace.boundingBox.minLatLng.longitude} \n\t\t Lat: ${fpasPlace.boundingBox.minLatLng.latitude}"), // meta_info_for_place_dialog_bounding_box_min
          Text("\n"),
          Text(
              "SubscriptionID: ${fpasPlace.subscriptionId}"), //meta_info_for_place_dialog_subscription_id
        ];
      } else {
        return [];
      }
    }

    return AlertDialog(
      title: Text(
          "${AppLocalizations.of(context)!.meta_info_for_place_dialog_headline} ${widget.myPlace.name}"),
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: generateMetaInfo(widget.myPlace)),
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
