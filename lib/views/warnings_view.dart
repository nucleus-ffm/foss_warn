import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/warnings.dart';
import 'package:foss_warn/widgets/connection_error_widget.dart';
import 'package:foss_warn/widgets/warning_widget.dart';

class WarningsView extends ConsumerWidget {
  const WarningsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var places = ref.watch(myPlacesProvider);
    var alerts = ref.watch(alertsProvider);

    if (places.isEmpty) {
      return const _NoPlacesConfigured();
    }

    if (alerts.isEmpty) {
      return const _NoWarnings();
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const ConnectionError(),
          for (var place in places) ...[
            for (var warning in alerts.where(
              (warning) => warning.placeSubscriptionId == place.subscriptionId,
            )) ...[
              WarningWidget(
                place: place,
                warnMessage: warning,
                isMyPlaceWarning: true,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _NoWarnings extends StatelessWidget {
  const _NoWarnings();

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;
    var theme = Theme.of(context);

    return Column(
      // else show a screen with
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
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
          ),
        ),
      ],
    );
  }
}

class _NoPlacesConfigured extends StatelessWidget {
  const _NoPlacesConfigured();

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ConnectionError(),
          ],
        ),
        Expanded(
          child: Center(
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
                  const Text("\n"),
                  Text(localizations.all_warnings_no_places_chosen_text),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
