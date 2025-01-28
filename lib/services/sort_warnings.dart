import 'package:foss_warn/enums/warning_source.dart';
import '../class/class_warn_message.dart';
import '../enums/severity.dart';
import '../main.dart';

// @todo write tests to verify
void sortWarnings(List<WarnMessage> list) {
  if (userPreferences.sortWarningsBy == "severity") {
    list.sort((a, b) => Severity.getIndexFromSeverity(a.info[0].severity)
        .compareTo(Severity.getIndexFromSeverity(b.info[0].severity)));
  } else if (userPreferences.sortWarningsBy == "date") {
    list.sort((a, b) => b.sent.compareTo(a.sent));
  } else if (userPreferences.sortWarningsBy == "source") {
    list.sort((a, b) => WarningSource.getIndexFromWarningSource(b.source)
        .compareTo(WarningSource.getIndexFromWarningSource(a.source)));
  }
}
