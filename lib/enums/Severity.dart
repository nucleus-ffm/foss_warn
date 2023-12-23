enum Severity {
  minor,
  moderate,
  severe,
  extreme;

  String toJson() => name;
  static Severity fromJson(String json) => values.byName(json);
}

/// extract the severity from the string and return the corresponding enum
Severity getSeverity(String severity) {
  for (Severity sev in Severity.values) {
    if (sev.name == severity) {
      return sev;
    }
  }

  return Severity.minor;
}

double getIndexFromSeverity(Severity notificationLevel) {
  final severities = Severity.values;
  for (int i = 0; i < severities.length; i++) {
    if (severities[i] == notificationLevel) {
      return i.toDouble();
    }
  }

  return 0;
}
