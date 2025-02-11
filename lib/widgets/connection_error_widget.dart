import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import 'dialogs/error_dialog.dart';

class ConnectionError extends StatelessWidget {
  const ConnectionError({super.key});

  @override
  Widget build(BuildContext context) {
    if (userPreferences.areWarningsFromCache) {
      return Container(
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 6, top: 6),
        //margin: EdgeInsets.only(bottom: 10),
        color: Colors.orange,
        child: Row(
          children: [
            Icon(
              Icons.info,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  AppLocalizations.of(context)!.connection_error_no_internet,
                  style: Theme.of(context).textTheme.displaySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      );
    } else if (appState.error) {
      // some error occurred
      return InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (BuildContext context) => ErrorDialog(),
        ),
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 6, top: 6),
          color: Theme.of(context).colorScheme.error,
          child: Row(
            children: [
              Icon(
                Icons.error,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    'Ups. Something went wrong. Please contact the developer',
                    // @todo translate app_error_message
                    style: Theme.of(context).textTheme.displaySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }
}
