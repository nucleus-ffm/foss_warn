import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/extensions/context.dart';

import '../map_widget.dart';

class MetaInfoForPlaceDialog extends ConsumerStatefulWidget {
  final Place myPlace;
  const MetaInfoForPlaceDialog({super.key, required this.myPlace});

  @override
  ConsumerState<MetaInfoForPlaceDialog> createState() =>
      _DeletePlaceDialogState();
}

class _DeletePlaceDialogState extends ConsumerState<MetaInfoForPlaceDialog> {
  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var navigator = Navigator.of(context);
    final MapController mapController = MapController();
    var mediaQuery = MediaQuery.of(context);

    var fpasPlace = widget.myPlace;

    List<Widget> generateMetaInfo(Place place) {
      return [
        SizedBox(
          width: mediaQuery.size.width * 0.7,
          height: 200,
          child: MapWidget(
            smallAttribution: true,
            initialCameraFit: CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(
                fpasPlace.boundingBox.getAsPolygon().points,
              ),
              padding: const EdgeInsets.all(30),
            ),
            mapController: mapController,
            widgets: const [],
            polygonLayers: [
              ...MapWidget.createSubscriptionsBoundingBox(ref),
            ],
            displayAllWarnings: false,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          "Bounding box max: \n\t\tLng: ${fpasPlace.boundingBox.maxLatLng.longitude}  \n\t\tLat: ${fpasPlace.boundingBox.maxLatLng.latitude}",
        ), // meta_info_for_place_dialog_bounding_box_max
        const SizedBox(height: 15),
        Text(
          "Bounding box min:\n\t\tLng: ${fpasPlace.boundingBox.minLatLng.longitude} \n\t\tLat: ${fpasPlace.boundingBox.minLatLng.latitude}",
        ), // meta_info_for_place_dialog_bounding_box_min
        const SizedBox(height: 15),
        SelectableText(
          "SubscriptionID:\n${fpasPlace.subscriptionId}",
        ), //meta_info_for_place_dialog_subscription_id
      ];
    }

    return AlertDialog(
      title: Text(
        "${localizations.meta_info_for_place_dialog_headline} ${widget.myPlace.name}",
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: generateMetaInfo(widget.myPlace),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () => navigator.pop(),
          child: Text(localizations.main_dialog_close),
        ),
      ],
    );
  }
}
