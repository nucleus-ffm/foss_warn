import 'package:foss_warn/enums/WarningSource.dart';
import '../class/class_WarnMessage.dart';
import '../enums/Severity.dart';
import '../main.dart';

void sortWarnings(List<WarnMessage> list) {
  if (userPreferences.sortWarningsBy == "severity") {
    list.sort((a, b) => Severity.getIndexFromSeverity(b.severity)
        .compareTo(Severity.getIndexFromSeverity(a.severity)));
  } else if (userPreferences.sortWarningsBy == "date") {
    list.sort((a, b) => b.sent.compareTo(a.sent));
  } else if (userPreferences.sortWarningsBy == "source") {
    list.sort((a, b) => WarningSource.getIndexFromWarningSource(b.source)
        .compareTo(WarningSource.getIndexFromWarningSource(a.source)));
  }
}
