import 'package:flutter/material.dart';
import 'package:foss_warn/main.dart';
import '../class/class_notificationPreferences.dart';
import '../enums/NotificationLevel.dart';
import '../enums/WarningSource.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../services/saveAndLoadSharedPreferences.dart';

class NotificationPreferencesListTileWidget extends StatefulWidget {
  final NotificationPreferences notificationPreferences;
  const NotificationPreferencesListTileWidget(
      {super.key, required this.notificationPreferences});

  @override
  State<NotificationPreferencesListTileWidget> createState() =>
      _NotificationPreferencesListTileWidgetState();
}

class _NotificationPreferencesListTileWidgetState
    extends State<NotificationPreferencesListTileWidget> {
  final EdgeInsets settingsTileListPadding = EdgeInsets.fromLTRB(25, 2, 25, 2);

  // return the label for the given value
  String getLabelForWarningSeverity(double sliderValue) {
    switch (sliderValue.toInt()) {
      case 3:
        return AppLocalizations.of(context)!
            .notification_settings_notify_by_minor;
      case 2:
        return AppLocalizations.of(context)!
            .notification_settings_notify_by_moderate;
      case 1:
        return AppLocalizations.of(context)!
            .notification_settings_notify_by_severe;
      case 0:
        return AppLocalizations.of(context)!
            .notification_settings_notify_by_extreme;
      default:
        return "Error";
    }
  }

  /// return the description for the given source
  String getDescriptionForEventSetting(WarningSource source) {
    switch (source) {
      case WarningSource.dwd:
        return AppLocalizations.of(context)!.source_dwd_description;
      case WarningSource.mowas:
        return AppLocalizations.of(context)!.source_mowas_description;
      case WarningSource.biwapp:
        return AppLocalizations.of(context)!.source_biwapp_description;
      case WarningSource.katwarn:
        return AppLocalizations.of(context)!.source_katwarn_description;
      case WarningSource.lhp:
        return AppLocalizations.of(context)!.source_lhp_description;
      case WarningSource.alertSwiss:
        return AppLocalizations.of(context)!.source_alertswiss_description;
      case WarningSource.other:
        return "Generelle Einstellung, die verwendet wird, wenn keine"
            " genauere Einstellung getroffen wurde.";
      default:
        return "Error";
    }
  }

  /// decide if a source can be disable
  bool SourceCanBeDisabled(WarningSource source) {
    switch (source) {
      case WarningSource.dwd:
        return true;
      case WarningSource.mowas:
        return false;
      case WarningSource.biwapp:
        return false;
      case WarningSource.katwarn:
        return false;
      case WarningSource.lhp:
        return true;
      case WarningSource.other:
        return false;
      default:
        return false;
    }
  }

  /// translate notification preferences into slider value
  double getValueForWarningLevel(NotificationLevel notificationPreferences) {
    switch (notificationPreferences) {
      case NotificationLevel.getUpToMinor:
        return 3;
      case NotificationLevel.getUpToModerate:
        return 2;
      case NotificationLevel.getUpToSevere:
        return 1;
      case NotificationLevel.getUpToExtreme:
        return 0;
      default:
        return 3;
    }
  }

  /// translate slider value into notification preferences
  NotificationLevel getNotificationPreferencesForValue(double value) {
    switch (value.toInt()) {
      case 0:
        return NotificationLevel.getUpToExtreme;
      case 1:
        return NotificationLevel.getUpToSevere;
      case 2:
        return NotificationLevel.getUpToModerate;
      case 3:
        return NotificationLevel.getUpToMinor;
      default:
        return NotificationLevel.disabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.notificationPreferences.warningSource ==
                WarningSource.alertSwiss &&
            !userPreferences.activateAlertSwiss
        ? SizedBox() // hide alert swiss if not activated
        : ListTile(
            contentPadding: settingsTileListPadding,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.notificationPreferences.warningSource.name
                      .toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                // show a switch when source can be disabled
                SourceCanBeDisabled(
                        widget.notificationPreferences.warningSource)
                    ? Switch(
                        value:
                            widget.notificationPreferences.notificationLevel !=
                                NotificationLevel.disabled,
                        onChanged: (value) {
                          // if source is enabled, set notificationLevel to getUpToMinor
                          // if source is disabled set notification level to disabled,
                          // the slider will be hidden when notification
                          // level is set to disabled
                          if (value) {
                            setState(() {
                              widget.notificationPreferences.notificationLevel =
                                  NotificationLevel.getUpToMinor;
                            });
                          } else {
                            setState(() {
                              widget.notificationPreferences.notificationLevel =
                                  NotificationLevel.disabled;
                            });
                          }
                          saveSettings();
                        },
                      )
                    : SizedBox(),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    getDescriptionForEventSetting(
                        widget.notificationPreferences.warningSource),
                    style: Theme.of(context).textTheme.bodyMedium),
                // hide the slider when source is disabled
                SourceCanBeDisabled(
                            widget.notificationPreferences.warningSource) &&
                        widget.notificationPreferences.notificationLevel ==
                            NotificationLevel.disabled
                    ? Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                            "Source disabled - you won't get a notification"), //@todo translate
                      )
                    : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(
                                Icons.notifications_active,
                                color: Colors.red,
                              ),
                              Flexible(
                                child: Slider(
                                  label: getLabelForWarningSeverity(
                                      getValueForWarningLevel(widget
                                          .notificationPreferences
                                          .notificationLevel)),
                                  divisions: 3,
                                  min: 0,
                                  max: 3,
                                  value: getValueForWarningLevel(widget
                                      .notificationPreferences
                                      .notificationLevel),
                                  onChanged: (value) {
                                    setState(
                                      () {
                                        print(widget.notificationPreferences
                                            .warningSource.name);
                                        // update notification level with slider value
                                        widget.notificationPreferences
                                                .notificationLevel =
                                            getNotificationPreferencesForValue(
                                                value);
                                      },
                                    );
                                  },
                                  onChangeEnd: (value) {
                                    // save settings, after change is complete
                                    saveSettings();
                                  },
                                ),
                              ),
                              Icon(
                                Icons.notifications,
                                color: Colors.orangeAccent,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Extrem"), // @todo translation
                                Text("Schwer"),
                                Text("Mittel"),
                                Text("Gering"),
                              ],
                            ),
                          )
                        ],
                      ),
              ],
            ),
          );
  }
}
