import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/services/save_and_load_shared_preferences.dart';
import '../../class/abstract_place.dart';
import '../../class/class_alert_swiss_place.dart';
import '../../class/class_nina_place.dart';
import '../../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../services/list_handler.dart';
import 'loading_screen.dart';

class LegacyWarningDialog extends StatefulWidget {
  const LegacyWarningDialog({super.key});

  @override
  State<LegacyWarningDialog> createState() => _LegacyWarningDialogState();
}

class _LegacyWarningDialogState extends State<LegacyWarningDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          "${AppLocalizations.of(context)!.legacy_warning_dialog_title} ${userPreferences.versionNumber}"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.legacy_warning_dialog_text)
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            debugPrint("Start migration process...");
            try {
              LoadingScreen.instance()
                  .show(context: context, text: "Start migration");
              List<Place> tempList = [...myPlaceList];
              myPlaceList.clear();
              debugPrint(tempList.toString());

              for (Place p in tempList) {
                bool foundPlace = false;
                if (!context.mounted) return;
                LoadingScreen.instance()
                    .show(context: context, text: "migrate ${p.name}");
                if (p is NinaPlace) {
                  for (Place searchPlace in allAvailablePlacesNames) {
                    if (searchPlace is NinaPlace) {
                      if (searchPlace.geocode.geocodeNumber
                                  .compareTo(p.geocode.geocodeNumber) ==
                              0 &&
                          searchPlace.name.contains(p.name)) {
                        debugPrint("found new place. ${searchPlace.name}");
                        debugPrint(
                            "found new place. found ${searchPlace.geocode.geocodeNumber} looking for ${p.geocode.geocodeNumber}  ");
                        myPlaceList.add(searchPlace);
                        foundPlace = true;
                        break;
                      }
                    }
                  }
                } else if (p is AlertSwissPlace) {
                  for (Place searchPlace in allAvailablePlacesNames) {
                    if (searchPlace is AlertSwissPlace) {
                      if (searchPlace.shortName.compareTo(p.shortName) == 0) {
                        myPlaceList.add(searchPlace);
                        foundPlace = true;
                        break;
                      }
                    }
                  }
                }
                // display error message if we didn't found a replacement for the place
                if (!foundPlace) {
                  LoadingScreen.instance().show(
                      context: context,
                      text: "No replacement was found for ${p.name}");
                  await Future.delayed(const Duration(seconds: 2));
                }
              }
              // sve new list
              if (!context.mounted) return;
              LoadingScreen.instance()
                  .show(context: context, text: "Done. saving new places");
              tempList.clear();
              // save new list
              saveMyPlacesList();
              await Future.delayed(const Duration(seconds: 2));
            } catch (e) {
              debugPrint("[legacyWarningDialog] Error: ${e.toString()}");
              if (!context.mounted) return;
              LoadingScreen.instance().show(
                  context: context,
                  text:
                      "Oh no. Something went wrong. It can not automatically migrate your places. Please do that manually.");
              await Future.delayed(const Duration(seconds: 3));
              ErrorLogger.writeErrorLog(
                  "legacyWarningDialog", "migration process", e.toString());
            }
            debugPrint("migration process done");
            LoadingScreen.instance().hide();
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context)!
                .legacy_warning_dialog_migration_button,
          ),
        ),
      ],
    );
  }
}
