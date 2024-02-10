enum Severity {
  Extreme,  // Extraordinary threat to life or property
  Severe,   // Significant threat to life or property
  Moderate, // Possible threat to life or property
  Minor,    // Minimal to no known threat to life or property
  Unknown;  // Severity unknown

  String toJson() => name;
  static Severity fromJson(String json) {
    try {
      return values.byName(json);
    } catch (e) {
      print("[Severity] no value found: " + e.toString());
      return Severity.Unknown;
    }
  }

  /// extract the severity from the string and return the corresponding enum
  static Severity fromString(String severity) {
    for (Severity sev in Severity.values) {
      if (sev.name == severity) {
        return sev;
      }
    }
    return Severity.Minor;
  }

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
}




