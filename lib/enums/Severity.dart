enum Severity {
  minor,
  moderate,
  extreme,
  severe,
  other;

  String toJson() => name;
  static Severity fromJson(String json) => values.byName(json);
}

/// extract the serverity from the string and return the corresponding enum
Severity getSeverity(String severity) {
  for(Severity sev in Severity.values ) {
    if(sev.name == severity) {
      return sev;
    }
  }
  return Severity.other;
}