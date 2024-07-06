import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../class/abstract_Place.dart';
import '../services/sortWarnings.dart';
import '../widgets/WarningWidget.dart';

class MyPlaceDetailScreen extends StatelessWidget {
  final Place _myPlace;
  const MyPlaceDetailScreen({Key? key, required Place myPlace})
      : _myPlace = myPlace, super(key: key);

  @override
  Widget build(BuildContext context) {
    sortWarnings(_myPlace.warnings); //@todo check if this works?

    return Scaffold(
      appBar: AppBar(
        title: Text("${_myPlace.name}"),
        actions: [
          IconButton(
            onPressed: () {
              _myPlace.markAllWarningsAsRead(context);
              final snackBar = SnackBar(
                content: Text(
                  AppLocalizations.of(context)
                      !.main_app_bar_tooltip_mark_all_warnings_as_read,
                ),
              );

              // Find the ScaffoldMessenger in the widget tree
              // and use it to show a SnackBar.
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            icon: Icon(Icons.mark_chat_read),
            tooltip: AppLocalizations.of(context)
                !.main_app_bar_tooltip_mark_all_warnings_as_read,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: _myPlace.warnings
              .map((warning) => WarningWidget(warnMessage: warning, isMyPlaceWarning: true,))
              .toList(),
        ),
      ),
    );
  }
}
