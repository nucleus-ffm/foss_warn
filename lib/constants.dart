const String defaultFPASServerUrl = "https://alerts.kde.org";
const String httpUserAgent =
    "FOSSWarn/1.0.1 (Android)"; //@TODO (Nucleus) fetch data automatically
const List<String> serverThatAreNotWorking = ["ntfy.sh"];
const List<String> serversWithIssues = ["unifiedpush.kde.org"];

/// this id is used when fetching alerts for the map view and storing
/// them temporarily in the list with the myPlaces alerts
const String noSubscriptionId = "no subscription";
