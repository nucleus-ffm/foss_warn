import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoWarningsInList extends StatelessWidget {
  const NoWarningsInList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        // else show a screen with
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      AppLocalizations.of(context)!.all_warnings_nothing_to_show,
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  Icon(
                    Icons.cloud,
                    size: 200,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(AppLocalizations.of(context)
                      !.all_warnings_nothing_to_show_text),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
