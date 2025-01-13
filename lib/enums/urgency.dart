enum Urgency {
  immediate, // Responsive action SHOULD be taken immediately
  expected, // Responsive action SHOULD be taken soon (within next hour)
  future, // Responsive action SHOULD be taken in the near future
  past, // Responsive action is no longer required
  unknown; // Urgency not known

  String toJson() => name;
  static Urgency fromJson(String json) => values.byName(json);

  /// extract the urgency from the string and return the corresponding enum
  static Urgency fromString(String urgency) {
    for (Urgency value in Urgency.values) {
      if (value.name == urgency.toLowerCase()) {
        return value;
      }
    }
    return Urgency.unknown; //@todo what should be the default value?
  }
}
