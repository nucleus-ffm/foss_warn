import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomeScreenItem {
  const WelcomeScreenItem(
      {required this.title,
      required this.description,
      required this.imagePath,
      this.action});

  final String title;
  final String description;
  final String imagePath;
  final String? action;
}

List<WelcomeScreenItem> getWelcomeScreenItems(BuildContext context) {
  return List.unmodifiable([
    WelcomeScreenItem(
        title: AppLocalizations.of(context)!.welcome_view_foss_warn_headline,
        description: AppLocalizations.of(context)!.welcome_view_foss_warn_text,
        imagePath: "assets/app_icon/app_icon.png"),
    WelcomeScreenItem(
        title: "FOSS Public Alert Server", //@todo translate welcome_view_foss_public_alert_server_headline
        description:
            // welcome_view_foss_public_alert_server_text
        "This version is an alpha test version of FOSSWarn with FPAS support. "
            "This version is not yet ready for production. ",
        imagePath: "assets/app_icon/app_icon.png",
        action: "FPAS" ),
    WelcomeScreenItem(
        title: AppLocalizations.of(context)!.welcome_view_important_headline,
        description: AppLocalizations.of(context)!.welcome_view_important_text,
        imagePath: "assets/paragraph.png",
        action: "disclaimer"),
    WelcomeScreenItem(
        title: "Notification Permission", // welcome_view_notification_permission_headline
        // welcome_view_notification_permission_text
        description: "FOSSWarn needs your permission to send you notification "
            "in case there is an alert for your area. Press on the button below"
            " to open the permission dialog.",
        imagePath: "assets/battery.png",
        action: "ask_permission_notification"),
    WelcomeScreenItem(
        title: "Alarm Permission ", // welcome_view_alarm_permission_headline
        // welcome_view_alarm_permission_text
        description: "FOSSWarn needs your permission to schedule exact alarms"
            "Press on the button below to open the permission dialog",
        imagePath: "assets/battery.png",
        action: "ask_permission_exact_alarm"),
    WelcomeScreenItem(
        title: AppLocalizations.of(context)!
            .welcome_view_battery_optimisation_headline,
        description: AppLocalizations.of(context)!
            .welcome_view_battery_optimisation_text,
        imagePath: "assets/battery.png",
        action: "batteryOptimization"),
    WelcomeScreenItem(
        title: AppLocalizations.of(context)!.welcome_view_my_places_headline,
        description: AppLocalizations.of(context)!.welcome_view_my_places_text,
        imagePath: "assets/location.png"),
    WelcomeScreenItem(
        title:
            AppLocalizations.of(context)!.welcome_view_warning_steps_headline,
        description:
            AppLocalizations.of(context)!.welcome_view_warning_steps_text,
        imagePath: "assets/steps.png"),
    WelcomeScreenItem(
        title: AppLocalizations.of(context)!.welcome_view_lets_go_headline,
        description: AppLocalizations.of(context)!.welcome_view_lets_go_text,
        imagePath: "assets/check.png")
  ]);
}
