import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/class/class_WarnMessage.dart';

import '../class/abstract_Place.dart';
import '../services/sortWarnings.dart';
import '../widgets/WarningWidget.dart';

class MyPlaceDetailScreen extends StatelessWidget {
  final Place _myPlace;
  const MyPlaceDetailScreen({Key? key, required Place myPlace})
      : _myPlace = myPlace,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    sortWarnings(_myPlace.warnings); //@todo check if this works?

    /// generate a threaded list of alerts with updates of alert as thread
    /// the returned data has the structure:
    /// [ [newest alert1, prev. alert1, ..., initial alert1], [newest alert2, prev. alert2, ..., initial alert2] ...]
    List<List<WarnMessage>> generateListOfAlerts() {
      List<List<WarnMessage>> result = [];

      for (WarnMessage wm in _myPlace.warnings) {
        List<WarnMessage> oneUpdateThread = [];

        if (wm.references != null) {
          // the alert contains a reference, so it is an update of an previous alert
          // we search for the alert and add it to the update thread

          oneUpdateThread
              .add(wm); // add the newest alert as first element of the thread
          for (String id in wm.references!.identifier) {
            // check all warnings for references
            for (WarnMessage alWm in _myPlace.warnings) {
              print(alWm.identifier);
              if (alWm.identifier.compareTo(id) == 0) {
                //print("found referenced alert: ${alWm.identifier}");
                // check if alert is already in the thread
                if (!oneUpdateThread
                    .any((element) => element.identifier == alWm.identifier)) {
                  oneUpdateThread.add(alWm);
                }
              }
            }
          }
        } else {
          // print("[myPlaceView] references: no references");
          // the alert is not referenced, so it is the newest version
          oneUpdateThread.add(wm);
        }
        result.add(oneUpdateThread);
      }
      // sort threads, newest warning should be first
      for (List<WarnMessage> thread in result) {
        thread.sort((a, b) => b.sent.compareTo(a.sent));
      }
      // print(result);
      return result;
    }

    /// build the list of warnings widgets. The first element of the threaded list is used
    /// and the remaining alerts are added as updateThread to the WarningWidget
    List<WarningWidget> buildWarningWidgets(
        List<List<WarnMessage>> listOfWarnings) {
      List<WarningWidget> result = [];

      for (List<WarnMessage> listWarn in listOfWarnings) {
        // do not show alerts for which there is a newer version of it
        // these alerts a only shown in the update thread
        if (!listWarn[0].hideWarningBecauseThereIsANewerVersion) {
          result.add(WarningWidget(
              warnMessage: listWarn[0],
              place: _myPlace,
              updateThread: listWarn));
        }
      }
      return result;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${_myPlace.name}"),
        actions: [
          IconButton(
            onPressed: () {
              _myPlace.markAllWarningsAsRead(context);
              final snackBar = SnackBar(
                content: Text(
                  AppLocalizations.of(context)!
                      .main_app_bar_tooltip_mark_all_warnings_as_read,
                ),
              );

              // Find the ScaffoldMessenger in the widget tree
              // and use it to show a SnackBar.
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            icon: Icon(Icons.mark_chat_read),
            tooltip: AppLocalizations.of(context)!
                .main_app_bar_tooltip_mark_all_warnings_as_read,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: buildWarningWidgets(generateListOfAlerts())
        ),
      ),
    );
  }
}
