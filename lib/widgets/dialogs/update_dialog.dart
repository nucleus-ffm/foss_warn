import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/widgets/map_widget.dart';
import 'package:latlong2/latlong.dart';

class UpdateDialog extends ConsumerStatefulWidget {
  const UpdateDialog({super.key});

  @override
  ConsumerState<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends ConsumerState<UpdateDialog> {
  final MapController mapController = MapController();

  Widget buildSubscriptionAreaOverview() {
    var subscriptions = ref.read(myPlacesProvider);
    List<Widget> result = [];
    for (var subscription in subscriptions) {
      result.add(
        Row(
          children: [
            Text(subscription.name),
            const SizedBox(
              width: 10,
            ),
            TextButton(
              onPressed: () {
                mapController.fitCamera(
                  CameraFit.bounds(
                    bounds: LatLngBounds.fromPoints(
                      subscription.boundingBox.getAsPolygon().points,
                    ),
                    padding: const EdgeInsets.all(30),
                  ),
                );
              },
              child: const Text("View area"),
            ),
          ],
        ),
      );
    }

    return Column(
      children: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    var navigator = Navigator.of(context);
    var localizations = context.localizations;
    var mediaQuery = MediaQuery.of(context);

    return AlertDialog(
      title: Text(localizations.update_dialog_title_v42),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(localizations.update_dialog_body_v42),
          const SizedBox(
            height: 10,
          ),
          Text(
            localizations.update_dialog_subscription_v42,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          buildSubscriptionAreaOverview(),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: mediaQuery.size.width * 0.7,
            height: 200,
            child: MapWidget(
              smallAttribution: true,
              initialCameraFit: const CameraFit.coordinates(
                padding: EdgeInsets.all(30),
                coordinates: [
                  LatLng(52.815, 7.009),
                  LatLng(53.264, 14.326),
                  LatLng(48.236, 12.964),
                  LatLng(48.704, 7.932),
                  LatLng(51.096, 6.746),
                ],
              ),
              mapController: mapController,
              widgets: const [],
              polygonLayers: [
                ...MapWidget.createSubscriptionsBoundingBox(ref),
              ],
              displayAllWarnings: false,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => navigator.pop(),
          child: Text(localizations.update_dialog_confirmation_v42),
        ),
      ],
    );
  }
}
