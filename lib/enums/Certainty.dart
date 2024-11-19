enum Certainty {
  Observed, // Determined to have occurred or to be ongoing
  Likely,   // Likely (p > ~50%)
  Possible, // Possible but not likely (p <=  ~50%)
  Unlikely, // Not expected to occur (p ~ 0)
  Unknown,  // Certainty unknown
  other;    // not part of CAP

  String toJson() => name;
  static Certainty fromJson(String json) => values.byName(json);
}

/// extract the certainty from the string and return the corresponding enum
Certainty getCertainty(String certainty) {
  for (Certainty cer in Certainty.values) {
    if (cer.name == certainty) {
      return cer;
    }
  }
  return Certainty.other;
}
