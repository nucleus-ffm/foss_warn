import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/extensions/list.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/warnings.dart';
import 'package:foss_warn/widgets/connection_error_widget.dart';
import 'package:foss_warn/widgets/warning_widget.dart';

class WarningsView extends ConsumerWidget {
  const WarningsView({
    required this.onAlertPressed,
    required this.onAlertUpdateThreadPressed,
    super.key,
  });

  final void Function(String alertId) onAlertPressed;
  final VoidCallback onAlertUpdateThreadPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var places = ref.watch(myPlacesProvider);

    // just to keep the timer running
    ref.watch(alertsProvider);
    var processedAlerts = ref.watch(processedAlertsProvider);

    // Just to detect if we have an error while polling for alerts.
    // We don't actually use the value otherwise.
    var alertsSnapshot = ref.watch(alertsFutureProvider);

    Widget body = SingleChildScrollView(
      child: Column(
        children: [
          for (var place in places) ...[
            for (var warning in processedAlerts.where(
              (warning) => warning.placeSubscriptionId == place.subscriptionId,
            )) ...[
              WarningWidget(
                place: place,
                warnMessage: warning,
                isMyPlaceWarning: true,
                onAlertPressed: onAlertPressed,
                onAlertUpdateThreadPressed: onAlertUpdateThreadPressed,
              ),
            ],
          ],
        ],
      ),
    );

    if (processedAlerts.isEmpty) {
      body = const _NoWarnings();
    }

    if (places.isEmpty) {
      body = const _NoPlacesConfigured();
    }

    return Column(
      children: [
        if (alertsSnapshot.hasError ||
            places.hasExpiredPlaces ||
            alertsSnapshot.isLoading) ...[
          //TODO
          const ConnectionError(),
        ],
        Expanded(child: body),
      ],
    );
  }
}

class _NoWarnings extends StatelessWidget {
  const _NoWarnings();

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;
    var theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              localizations.all_warnings_everything_ok,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              Icons.check_circle_rounded,
              size: 200,
              color: theme.colorScheme.secondary,
            ),
            Text(
              localizations.all_warnings_everything_ok_text,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoPlacesConfigured extends StatelessWidget {
  const _NoPlacesConfigured();

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              localizations.all_warnings_no_places_chosen,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(localizations.my_place_no_place_added_text),
          ],
        ),
      ),
    );
  }
}
