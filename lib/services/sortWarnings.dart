import 'package:foss_warn/enums/Severity.dart';

import '../main.dart';
import 'listHandler.dart';

/// used to sort warning
/// returns an int corresponding to the severity
int convertSeverityToInt(Severity severity) {
  switch (severity) {
    case Severity.minor:
    case Severity.other:
      return 0;
    case Severity.moderate:
      return 1;
    case Severity.extreme:
      return 2;
    case Severity.severe:
      return 3;
  }
}

/// used to sort warning
int convertSourceToInt(String source) {
  switch (source) {
    case "MOWAS":
      return 0;
    case "KATWARN":
      return 1;
    case "BIWAPP":
      return 2;
    case "DWD":
      return 3;
  }
  return 0;
}

void sortWarnings() {
  if (userPreferences.sortWarningsBy == "severity") {
    warnMessageList.sort((a, b) => convertSeverityToInt(b.severity)
        .compareTo(convertSeverityToInt(a.severity)));
  } else if (userPreferences.sortWarningsBy == "date") {
    warnMessageList.sort((a, b) => b.sent.compareTo(a.sent));
  } else if (userPreferences.sortWarningsBy == "source") {
    warnMessageList.sort((a, b) => convertSourceToInt(b.publisher)
        .compareTo(convertSourceToInt(a.publisher)));
  }
}
