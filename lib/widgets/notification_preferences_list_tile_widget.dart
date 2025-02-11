import 'package:flutter/material.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/main.dart';
import '../class/class_notification_preferences.dart';
import '../enums/warning_source.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../services/save_and_load_shared_preferences.dart';

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
      case 0:
        return AppLocalizations.of(context)!
            .notification_settings_notify_by_extreme;
      case 1:
        return AppLocalizations.of(context)!
            .notification_settings_notify_by_severe;
      case 2:
        return AppLocalizations.of(context)!
            .notification_settings_notify_by_moderate;
      case 3:
        return AppLocalizations.of(context)!
            .notification_settings_notify_by_minor;
      default:
        return "Error";
    }
  }

  /// return the description for the given source
  String _getDescriptionForEventSetting(WarningSource source) {
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
        return AppLocalizations.of(context)!.source_other_description;
      default:
        return "Error";
    }
  }

  /// decide if a source can be disabled
  bool _isTogglableSource(WarningSource source) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: settingsTileListPadding,
          child: Divider(),
        ),
        ListTile(
          contentPadding: settingsTileListPadding,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.notificationPreferences.warningSource.name.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              // show a switch when source can be disabled
              if (_isTogglableSource(
                  widget.notificationPreferences.warningSource))
                Switch(
                  value: !widget.notificationPreferences.disabled,
                  onChanged: (value) {
                    // the slider will be hidden when source is disabled
                    setState(() {
                      widget.notificationPreferences.disabled = !value;
                    });
                  },
                )
              else
                SizedBox(),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  _getDescriptionForEventSetting(
                      widget.notificationPreferences.warningSource),
                  style: Theme.of(context).textTheme.bodyMedium),
              // hide the slider when source is disabled
              if (_isTogglableSource(
                      widget.notificationPreferences.warningSource) &&
                  widget.notificationPreferences.disabled)
                Container(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(AppLocalizations.of(context)!
                      .notification_settings_source_disabled),
                )
              else
                Column(
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
                                Severity.getIndexFromSeverity(widget
                                    .notificationPreferences
                                    .notificationLevel)),
                            divisions: 3,
                            min: 0,
                            max: 3,
                            value: Severity.getIndexFromSeverity(widget
                                .notificationPreferences.notificationLevel),
                            onChanged: (value) {
                              setState(
                                () {
                                  final notificationLevel =
                                      Severity.values[value.toInt()];

                                  debugPrint(
                                      "${widget.notificationPreferences.warningSource.name}:$notificationLevel");

                                  // update notification level with slider value
                                  widget.notificationPreferences
                                      .notificationLevel = notificationLevel;
                                },
                              );
                            },
                            onChangeEnd: (value) {
                              // save settings, after change is complete
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
                          Text(AppLocalizations.of(context)!
                              .notification_settings_slidervalue_extreme),
                          Text(AppLocalizations.of(context)!
                              .notification_settings_slidervalue_severe),
                          Text(AppLocalizations.of(context)!
                              .notification_settings_slidervalue_moderate),
                          Text(AppLocalizations.of(context)!
                              .notification_settings_slidervalue_minor),
                        ],
                      ),
                    )
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
