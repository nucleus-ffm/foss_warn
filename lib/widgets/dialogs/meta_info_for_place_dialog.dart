import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/extensions/context.dart';

class MetaInfoForPlaceDialog extends StatefulWidget {
  final Place myPlace;
  const MetaInfoForPlaceDialog({super.key, required this.myPlace});

  @override
  State<MetaInfoForPlaceDialog> createState() => _DeletePlaceDialogState();
}

class _DeletePlaceDialogState extends State<MetaInfoForPlaceDialog> {
  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var navigator = Navigator.of(context);

    var fpasPlace = widget.myPlace;

    List<Text> generateMetaInfo(Place place) {
      return [
        Text(
            "Bounding box max: \n\t\tLng: ${fpasPlace.boundingBox.maxLatLng.longitude}  \n\t\tLat: ${fpasPlace.boundingBox.maxLatLng.latitude}"), // meta_info_for_place_dialog_bounding_box_max
        Text("\n"),
        Text(
            "Bounding box min:\n\t\t Lng: ${fpasPlace.boundingBox.minLatLng.longitude} \n\t\t Lat: ${fpasPlace.boundingBox.minLatLng.latitude}"), // meta_info_for_place_dialog_bounding_box_min
        Text("\n"),
        Text(
            "SubscriptionID: ${fpasPlace.subscriptionId}"), //meta_info_for_place_dialog_subscription_id
      ];
    }

    return AlertDialog(
      title: Text(
        "${localizations.meta_info_for_place_dialog_headline} ${widget.myPlace.name}",
      ),
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: generateMetaInfo(widget.myPlace)),
      actions: <Widget>[
        ElevatedButton(
            onPressed: () => navigator.pop(),
            child: Text(localizations.main_dialog_close)),
      ],
    );
  }
}
