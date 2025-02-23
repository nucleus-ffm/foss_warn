import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/services/check_for_my_places_warnings.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/widgets/connection_error_widget.dart';
import 'package:foss_warn/widgets/warning_widget.dart';

class WarningsView extends ConsumerWidget {
  const WarningsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);

    var alertApi = ref.watch(alertApiProvider);
    var myPlacesService = ref.read(myPlacesProvider.notifier);

    var places = ref.watch(myPlacesProvider);
    var isAnyPlaceWithWarning =
        places.any((place) => place.warnings.isNotEmpty);

    Future<void> onRefresh() async {
      await checkForMyPlacesWarnings(
        alertApi: alertApi,
        myPlacesService: myPlacesService,
        places: places,
      );
    }

    if (places.isNotEmpty && !isAnyPlaceWithWarning) {
      // TODO(PureTryOut): do this automatically in the background somewhere
      // Right now this is done on every rebuild, probably not what we want but won't be terrible
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await onRefresh();
      });
    }

    Widget body = _NoWarnings(onReloadPressed: onRefresh);

    if (places.isEmpty) {
      body = const _NoPlacesConfigured();
    }

    if (isAnyPlaceWithWarning) {
      body = SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const ConnectionError(),
            for (var place in places) ...[
              for (var warning in place.warnings) ...[
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

    return RefreshIndicator(
      color: theme.colorScheme.secondary,
      onRefresh: onRefresh,
      child: body,
    );
  }
}

class _NoWarnings extends StatelessWidget {
  const _NoWarnings({required this.onReloadPressed});

  final VoidCallback onReloadPressed;

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
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: onReloadPressed,
                    style: TextButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                    child: Text(
                      localizations.all_warnings_reload,
                      style: TextStyle(
                        color: theme.colorScheme.onSecondary,
                      ),
                    ),
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
