import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

enum Category {
  /// Geophysical (inc. landslide)
  geo,

  /// Meteorological (inc. flood)
  met,

  /// General emergency and public safety
  safety,

  /// Rescue and recovery
  rescue,

  /// Fire suppression and rescue
  fire,

  /// Medical and public health
  health,

  /// Pollution and other environmental
  env,

  /// Public and private   transportation
  transport,

  /// Utility, telecommunication, other  non-transport infrastructure
  infra,

  /// Chemical, Biological, Radiological, Nuclear or High-Yield Explosive threat or attack
  cbrne,

  /// Other events
  other;

  String toJson() => name;
  // static Category fromJson(String json) => values.byName(json);

  static List<Category> categoryListFromJson(List<String>? data) {
    List<Category> result = [];
    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        result.add(Category.fromString(data[i]));
      }
    }
    return result;
  }

  /// parse json data to enum value
  static Category fromJson(String json) {
    try {
      return values.byName(json.toLowerCase());
    } catch (e) {
      debugPrint("[Category] no value found: $e");
      return Category.other;
    }
  }

  /// extract the severity from the string and return the corresponding enum
  static Category fromString(String category) {
    for (Category cat in Category.values) {
      if (cat.name == category.toLowerCase()) {
        return cat;
      }
    }
    return Category.other; //@todo what should be the default value?
  }

  String getLocalizedName(BuildContext context) {
    var localizations = context.localizations;

    return switch (this) {
      geo => localizations.explanation_environment,
      met => localizations.explanation_weather,
      safety => localizations.explanation_safety,
      rescue => localizations.explanation_rescue,
      fire => localizations.explanation_fire,
      health => localizations.explanation_health,
      env => localizations.explanation_environment,
      transport => localizations.explanation_transport,
      infra => localizations.explanation_infrastructure,
      cbrne => localizations.explanation_CBRNE,
      other => localizations.explanation_other,
    };
  }

  String getLocalizedExplanation(BuildContext context) {
    var localizations = context.localizations;
    return switch (this) {
      geo => localizations.explanation_environment_text,
      met => localizations.explanation_weather_text,
      safety => localizations.explanation_safety_text,
      rescue => localizations.explanation_rescue_text,
      fire => localizations.explanation_fire_text,
      health => localizations.explanation_health_text,
      env => localizations.explanation_environment_text,
      transport => localizations.explanation_transport_text,
      infra => localizations.explanation_infrastructure_text,
      cbrne => localizations.explanation_CBRNE_text,
      other => localizations.explanation_other_text,
    };
  }
}
