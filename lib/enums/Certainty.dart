enum Certainty {
  Observed,
  other
}

/// extract the serverity from the string and return the corresponding enum
Certainty getCertainty(String certainty) {
  for(Certainty cer in Certainty.values ) {
    if(cer.name == certainty) {
      return cer;
    }
  }
  return Certainty.other;
}