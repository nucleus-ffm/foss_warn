import '../main.dart';
import 'listHandler.dart';

/// used to sort warning
/// returns an int corresponding to the severity
int convertSeverityToInt(String severity) {
  switch (severity) {
    case "Minor":
      return 0;
    case "Moderate":
      return 1;
    case "Extrem":
      return 2;
    case "Severe":
      return 3;
  }
  return 0;
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
    allWarnMessageList.sort((a, b) => convertSeverityToInt(b.severity.name)
        .compareTo(convertSeverityToInt(a.severity.name)));
  } else if (userPreferences.sortWarningsBy == "date") {
    allWarnMessageList.sort((a, b) => b.sent.compareTo(a.sent));
  } else if (userPreferences.sortWarningsBy == "source") {
    allWarnMessageList.sort((a, b) => convertSourceToInt(b.publisher)
        .compareTo(convertSourceToInt(a.publisher)));
  }
}
