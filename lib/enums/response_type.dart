import 'package:flutter/cupertino.dart';

import '../extensions/context.dart';

enum ResponseType {
  /// Take shelter in place or per `<instruction>`
  shelter,

  /// Relocate as instructed in the `<instruction>`
  evacuate,

  /// Make preparations per the `<instruction>`
  prepare,

  /// Execute a pre-planned activity identified in `<instruction>`
  execute,

  /// Avoid the subject event as per the `<instruction>`
  avoid,

  /// Attend to information sources as described in `<instruction>`
  monitor,

  /// Evaluate the information in this  message. (This value SHOULD NOT be used in public warning applications.)
  //assess,

  /// The subject event no longer poses a threat or concern and any follow action is described in `<instruction>`
  allclear,

  /// No action recommended
  none,

  /// Fallback value if the value in the alert is valid
  unknown;

  String toJson() => name;
  static ResponseType fromJson(var json) {
    try {
      if (json is String) {
        return values.byName(json.toLowerCase());
      }
      return unknown;
    } catch (e) {
      return unknown;
    }
  }

  static List<ResponseType> fromJsonList(var json) {
    List<ResponseType> result = [];
    try {
      if (json == null) {
        return [];
      }
      if (json is List) {
        for (var entry in json) {
          result.add(ResponseType.fromJson(entry));
        }
      } else {
        result.add(ResponseType.fromJson(json));
      }
    } catch (e) {
      // nothing to do here. Maybe add to logger later
    }
    return result;
  }

  /// extract the severity from the string and return the corresponding enum
  static ResponseType fromString(String responseType) {
    for (ResponseType value in ResponseType.values) {
      if (value.name.toLowerCase() == responseType.toLowerCase()) {
        return value;
      }
    }
    return ResponseType.none; //@todo what should be the default value?
  }

  /// Return the localized name
  String getLocalizedName(BuildContext context) {
    var localizations = context.localizations;
    return switch (this) {
      ResponseType.shelter => localizations.warning_response_type_shelter,
      ResponseType.evacuate => localizations.warning_response_type_evacuate,
      ResponseType.prepare => localizations.warning_response_type_prepare,
      ResponseType.execute => localizations.warning_response_type_execute,
      ResponseType.avoid => localizations.warning_response_type_avoid,
      ResponseType.monitor => localizations.warning_response_type_monitor,
      ResponseType.allclear => localizations.warning_response_type_allclear,
      ResponseType.none => localizations.warning_response_type_none,
      ResponseType.unknown => localizations.warning_response_type_unknown
    };
  }

  /// Return the localized explanation
  String getLocalizedExplanation(BuildContext context) {
    var localizations = context.localizations;
    return switch (this) {
      ResponseType.shelter =>
        localizations.warning_response_type_shelter_explanation,
      ResponseType.evacuate =>
        localizations.warning_response_type_evacuate_explanation,
      ResponseType.prepare =>
        localizations.warning_response_type_prepare_explanation,
      ResponseType.execute =>
        localizations.warning_response_type_execute_explanation,
      ResponseType.avoid =>
        localizations.warning_response_type_avoid_explanation,
      ResponseType.monitor =>
        localizations.warning_response_type_monitor_explanation,
      ResponseType.allclear =>
        localizations.warning_response_type_allclear_explanation,
      ResponseType.none => localizations.warning_response_type_none_explanation,
      ResponseType.unknown =>
        localizations.warning_response_type_unknown_explanation
    };
  }
}
