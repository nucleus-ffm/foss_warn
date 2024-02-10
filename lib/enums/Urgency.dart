enum Urgency {
  Immediate,  // Responsive action SHOULD be taken immediately
  Expected,   // Responsive action SHOULD be taken soon (within next hour)
  Future,     // Responsive action SHOULD be taken in the near future
  Past,       // Responsive action is no longer required
  Unknown;    // Urgency not known

  String toJson() => name;
  static Urgency fromJson(String json) => values.byName(json);

  /// extract the urgency from the string and return the corresponding enum
  static Urgency fromString(String urgency) {
    for (Urgency value in Urgency.values) {
      if (value.name == urgency) {
        return value;
      }
    }
    return Urgency.Unknown; //@todo what should be the default value?
  }
}
