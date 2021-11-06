import '../SettingsView.dart';
import 'listHandler.dart';

void sortWarnings() {
  if(sortWarningsBy == "severity") {
    warnMessageList.sort((a, b) => b.severity.compareTo(a.severity));
  } else if(sortWarningsBy == "date") {
    warnMessageList.sort((a, b) => b.sent.compareTo(a.sent));
  } else if(sortWarningsBy =="source") {
    warnMessageList.sort((a, b) => b.publisher.compareTo(a.publisher));
  }
}