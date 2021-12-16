import '../views/SettingsView.dart';
import 'listHandler.dart';

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
  if(sortWarningsBy == "severity") {
    warnMessageList.sort((a, b) => convertSeverityToInt(b.severity).compareTo(convertSeverityToInt(a.severity)));
  } else if(sortWarningsBy == "date") {
    warnMessageList.sort((a, b) => b.sent.compareTo(a.sent));
  } else if(sortWarningsBy == "source") {
    warnMessageList.sort((a, b) => convertSourceToInt(b.publisher).compareTo(convertSourceToInt(a.publisher)));
  }
}