import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/widgets/warning_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../class/class_bounding_box.dart';
import '../class/class_warn_message.dart';
import '../constants.dart' as constants;
import '../services/alert_api/fpas.dart';
import '../services/api_handler.dart';
import '../services/warnings.dart';

class MapAlertSheet extends StatefulWidget {
  final WidgetRef ref;
  final LatLng latLng;
  const MapAlertSheet(this.latLng, this.ref, {super.key});

  @override
  State<MapAlertSheet> createState() => _MapAlertSheetState();
}

class _MapAlertSheetState extends State<MapAlertSheet> {
  late final Future<Widget?> _future;

  /// Get the alerts for the selected point on the map
  Future<List<WarnMessage>> getAlerts(LatLng coordinates) async {
    var alertApi = widget.ref.read(alertApiProvider);
    List<WarnMessage> alerts = [];
    double areaSelectionRadius = 0.001;
    // construct the bounding box around the selected point on the map to fetch
    // the alerts for this area
    BoundingBox boundingBox = BoundingBox(
      minLatLng: LatLng(
        coordinates.latitude + areaSelectionRadius,
        coordinates.longitude - areaSelectionRadius,
      ),
      maxLatLng: LatLng(
        coordinates.latitude - areaSelectionRadius,
        coordinates.longitude + areaSelectionRadius,
      ),
    );
    List<AlertApiResult> results =
        await alertApi.getAlertsForArea(boundingBox: boundingBox);
    if (results != []) {
      alerts = await Future.wait(
        [
          for (var alert in results) ...[
            alertApi.getAlertDetail(
              alertId: alert.alertId,
              placeSubscriptionId: constants.noSubscriptionId,
            ),
          ],
        ],
      ).catchError((exception) {
        debugPrint(
          "[map_widget] Something went wrong while fetching alert details $exception",
        );
        return alerts;
      });
    }
    for (var alert in alerts) {
      widget.ref.read(processedAlertsProvider.notifier).updateAlert(alert);
    }
    return alerts;
  }

  List<Widget> buildAlertList(List<WarnMessage> alerts, BuildContext context) {
    List<Widget> result = [];
    for (WarnMessage alert in alerts) {
      result.add(
        WarningWidget(
          warnMessage: alert,
          isMyPlaceWarning: false,
          onAlertPressed: (String alertId, String subscriptionId) =>
              context.go('/alerts/$alertId/$subscriptionId'),
          onAlertUpdateThreadPressed: () => {},
        ),
      );
    }
    return result;
  }

  Future<Widget?> alertSelectionSheet(
    LatLng coordinates,
    BuildContext context,
  ) async {
    var localization = context.localizations;
    List<WarnMessage> alerts = await getAlerts(coordinates);
    if (alerts.isEmpty) {
      return null;
    }
    if (!context.mounted) return const Column();
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              left: 8.0,
              right: 8.0,
              bottom: 8.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localization.map_alert_sheet_title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                ...buildAlertList(
                  alerts,
                  context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _future = alertSelectionSheet(widget.latLng, context);
  }

  @override
  void dispose() {
    Future(() {
      // remove all added alerts again
      // do that in a Future to avoid manipulating
      // the widget tree while building
      var alerts = widget.ref.read(processedAlertsProvider);
      List<WarnMessage> alertsToDelete = [];
      for (WarnMessage alert in alerts) {
        if (alert.placeSubscriptionId == constants.noSubscriptionId) {
          alertsToDelete.add(alert);
        }
      }
      widget.ref
          .read(processedAlertsProvider.notifier)
          .deleteMultipleAlerts(alertsToDelete);
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) return snapshot.data!;
          if (snapshot.hasError) return const SizedBox();
        }
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.35,
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}