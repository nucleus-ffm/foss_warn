import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

import '../main.dart';
import 'dialogs/error_dialog.dart';

class ConnectionError extends StatelessWidget {
  const ConnectionError({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var theme = Theme.of(context);

    if (userPreferences.areWarningsFromCache) {
      return Container(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 6, top: 6),
        //margin: EdgeInsets.only(bottom: 10),
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
    } else if (appState.error) {
      // some error occurred
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
    } else {
      return const SizedBox();
    }
  }
}
