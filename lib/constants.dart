const String defaultFPASServerUrl = "alerts.kde.org";
const String httpUserAgent =
    "FOSSWarn/1.1.0 (Android)"; //@TODO (Nucleus) fetch data automatically
const List<String> serverThatAreNotWorking = ["ntfy.sh"];
const List<String> serversWithIssues = ["unifiedpush.kde.org"];

/// this id is used when fetching alerts for the map view and storing
/// them temporarily in the list with the myPlaces alerts
const String noPlaceId = "no place id";
const String localOnlyId = "-1";

const int alarmManagerTaskIdPolling = 1;
const int alarmManagerTaskIdLocation = 2;

const String unifiedPushInstance = "FOSSWarn";
const String unifiedPushMessageForDistributor = "FOSSWarn notifications";
