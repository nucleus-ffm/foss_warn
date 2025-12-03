import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

enum AlertService {
  push,
  poll,
  pushAndPoll,
  nothing;

  String toJson() => name;
  static AlertService fromJson(String json) =>
      values.byName(json.toLowerCase());

  String getLocalizedName(BuildContext context) {
    var localizations = context.localizations;

    return switch (this) {
      push => localizations.alert_service_push,
      poll => localizations.alert_service_poll,
      pushAndPoll => localizations.alert_service_push_and_poll,
      nothing => localizations.alert_service_nothing,
    };
  }
}
