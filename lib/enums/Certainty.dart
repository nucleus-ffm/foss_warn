enum Certainty {
  observed,
  other;

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
