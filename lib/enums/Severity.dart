enum Severity {
  extreme,
  severe,
  moderate,
  minor;

  String toJson() => name;
  static Severity fromJson(String json) => values.byName(json);

  static double getIndexFromSeverity(Severity notificationLevel) {
    final severities = Severity.values;
    for (int i = 0; i < severities.length; i++) {
      if (severities[i] == notificationLevel) {
        return i.toDouble();
      }
    }

    // default return value: index of Severity.minor
    return 3;
  }

  /// extract the severity from the string and return the corresponding enum
  static Severity getSeverity(String severity) {
    for (Severity sev in Severity.values) {
      if (sev.name == severity) {
        return sev;
      }
    }

    return Severity.minor;
  }

}




