enum Certainty {
  observed, // Determined to have occurred or to be ongoing
  likely, // Likely (p > ~50%)
  possible, // Possible but not likely (p <=  ~50%)
  unlikely, // Not expected to occur (p ~ 0)
  unknown, // Certainty unknown
  other; // not part of CAP

  String toJson() => name;
  static Certainty fromJson(String json) => values.byName(json.toLowerCase());
}

/// extract the certainty from the string and return the corresponding enum
Certainty getCertainty(String certainty) {
  for (Certainty cer in Certainty.values) {
    if (cer.name == certainty.toLowerCase()) {
      return cer;
    }
  }
  return Certainty.other;
}
