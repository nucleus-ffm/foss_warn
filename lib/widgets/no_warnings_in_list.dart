import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

class NoWarningsInList extends StatelessWidget {
  const NoWarningsInList({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var theme = Theme.of(context);

    return SizedBox(
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
                    localizations.all_warnings_nothing_to_show,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.cloud,
                    size: 200,
                    color: theme.colorScheme.primary,
                  ),
                  Text(localizations.all_warnings_nothing_to_show_text),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
