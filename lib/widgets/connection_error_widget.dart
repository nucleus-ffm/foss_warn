import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/extensions/context.dart';

import 'dialogs/error_dialog.dart';

class ConnectionError extends ConsumerWidget {
  const ConnectionError({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var localizations = context.localizations;
    var theme = Theme.of(context);

    var userPreferences = ref.watch(userPreferencesProvider);

    if (userPreferences.areWarningsFromCache) {
      return Container(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 6, top: 6),
        color: Colors.orange,
        child: Row(
          children: [
            const Icon(
              Icons.info,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
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

    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (BuildContext context) => const ErrorDialog(),
      ),
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 6, top: 6),
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
}
