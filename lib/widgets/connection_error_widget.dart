import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/extensions/context.dart';

import '../main.dart';
import '../services/list_handler.dart';
import 'dialogs/error_dialog.dart';
import 'dialogs/invalid_subscription_dialog.dart';

class ConnectionError extends ConsumerWidget {
  const ConnectionError({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var localizations = context.localizations;
    var myPlaceProvider = ref.watch(myPlacesProvider.notifier);
    ThemeData theme = Theme.of(context);

    Widget warningsFromCache() {
      return Container(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 6, top: 6),
        color: Colors.orange,
        child: Row(
          children: [
            const Icon(
              Icons.info,
              color: Colors.white,
            ),
            const SizedBox(
              width: 10,
            ),
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  localizations.connection_error_no_internet,
                  style: Theme.of(context).textTheme.displaySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget appError() {
      return InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (BuildContext context) => const ErrorDialog(),
        ),
        child: Container(
          padding:
              const EdgeInsets.only(left: 10, right: 10, bottom: 6, top: 6),
          color: theme.colorScheme.error,
          child: Row(
            children: [
              const Icon(
                Icons.error,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    localizations.connection_error_app_error,
                    style: theme.textTheme.displaySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget invalidSubscriptionError() {
      return InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (BuildContext context) => const InvalidSubscriptionDialog(),
        ),
        child: Container(
          padding:
              const EdgeInsets.only(left: 10, right: 10, bottom: 6, top: 6),
          color: theme.colorScheme.error,
          child: Row(
            children: [
              const Icon(
                Icons.error,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    localizations.connection_error_subscription_expired,
                    style: theme.textTheme.displaySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (userPreferences.areWarningsFromCache) {
      return warningsFromCache();
    } else if (appState.error) {
      return appError();
    } else if (myPlaceProvider.places.any((p) => p.isExpired)) {
      return invalidSubscriptionError();
    } else {
      return const SizedBox();
    }
  }
}
