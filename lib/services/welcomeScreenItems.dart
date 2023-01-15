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

List<WelcomeScreenItem> getWelcomeScreenItems(BuildContext context)  {
  return
 List.unmodifiable([
  WelcomeScreenItem(
      title: AppLocalizations.of(context).welcome_view_foss_warn_headline,
      description:
      AppLocalizations.of(context).welcome_view_foss_warn_text,
      imagePath: "assets/app_icon.png"),
  WelcomeScreenItem(
      title: AppLocalizations.of(context).welcome_view_important_headline,
      description:
      AppLocalizations.of(context).welcome_view_important_text,
      imagePath: "assets/paragraph.png",
      action: "disclaimer"),
  WelcomeScreenItem(
      title: AppLocalizations.of(context).welcome_view_battery_optimisation_headline,
      description: AppLocalizations.of(context).welcome_view_battery_optimisation_text,
      imagePath: "assets/battery.png",
      action: "batteryOptimization"),
  WelcomeScreenItem(
      title: AppLocalizations.of(context).welcome_view_my_places_headline,
      description: AppLocalizations.of(context).welcome_view_my_places_text,
      imagePath: "assets/location.png"),
  WelcomeScreenItem(
      title: AppLocalizations.of(context).welcome_view_warning_steps_headline,
      description: AppLocalizations.of(context).welcome_view_warning_steps_text,
      imagePath: "assets/steps.png"),
  WelcomeScreenItem(
      title: AppLocalizations.of(context).welcome_view_lets_go_headline,
      description:
      AppLocalizations.of(context).welcome_view_lets_go_text,
      imagePath: "assets/check.png")
  ]);
}
