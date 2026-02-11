import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/warnings.dart';

import '../widgets/warning_widget.dart';
import '../widgets/warning_widget_tv.dart';

//@todo rename to MyPlacesDetailView
class MyPlaceDetailScreen extends ConsumerWidget {
  const MyPlaceDetailScreen({
    required this.placeSubscriptionId,
    required this.onAlertPressed,
    required this.onAlertUpdateThreadPressed,
    super.key,
  });

  final String placeSubscriptionId;
  final void Function(String alertId, String subscriptionId) onAlertPressed;
  final void Function() onAlertUpdateThreadPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var localizations = context.localizations;
    var scaffoldMessenger = ScaffoldMessenger.of(context);

    var place = ref.read(
      myPlacesProvider.select(
        (value) => value.firstWhere(
          (element) => element.subscriptionId == placeSubscriptionId,
        ),
      ),
    );

    var warnings = ref.watch(
      processedAlertsProvider.select(
        (warnings) => warnings.where(
          (warning) => warning.placeSubscriptionId == place.subscriptionId,
        ),
      ),
    );

    /// generate a threaded list of alerts with updates of alert as thread
    /// the returned data has the structure:
    /// [ [newest alert1, prev. alert1, ..., initial alert1], [newest alert2, prev. alert2, ..., initial alert2] ...]
    List<List<WarnMessage>> generateListOfAlerts() {
      List<List<WarnMessage>> result = [];

      for (var wm in warnings) {
        List<WarnMessage> oneUpdateThread = [];

        if (wm.references != null) {
          // the alert contains a reference, so it is an update of an previous alert
          // we search for the alert and add it to the update thread

          oneUpdateThread
              .add(wm); // add the newest alert as first element of the thread
          for (String id in wm.references!.identifier) {
            // check all warnings for references
            for (var alWm in warnings) {
              debugPrint(alWm.identifier);
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
    List<WarningWidgetTV> buildWarningWidgets(
      List<List<WarnMessage>> listOfWarnings,
    ) {
      List<WarningWidgetTV> result = [];

      for (List<WarnMessage> listWarn in listOfWarnings) {
        // do not show alerts for which there is a newer version of it
        // these alerts a only shown in the update thread
        if (!listWarn[0].hideWarningBecauseThereIsANewerVersion) {
          result.add(
            WarningWidgetTV(
              onAlertPressed: onAlertPressed,
              onAlertUpdateThreadPressed: onAlertUpdateThreadPressed,
              warnMessage: listWarn[0],
              place: place,
              updateThread: listWarn,
              isMyPlaceWarning: true,
            ),
          );
        }
      }
      return result;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
        actions: [
          IconButton(
            onPressed: () {
              markAllWarningsAsRead(ref);

              final snackBar = SnackBar(
                content: Text(
                  localizations.main_app_bar_tooltip_mark_all_warnings_as_read,
                ),
              );

              scaffoldMessenger.showSnackBar(snackBar);
            },
            icon: const Icon(Icons.mark_chat_read),
            tooltip:
                localizations.main_app_bar_tooltip_mark_all_warnings_as_read,
          ),
        ],
      ),
      body: SingleChildScrollView(
        //scrollDirection: Axis.horizontal,
        child: Column(children: buildWarningWidgets(generateListOfAlerts())),
      ),
    );
  }
}
