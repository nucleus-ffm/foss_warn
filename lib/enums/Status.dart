enum Status {
  Actual,   // Actionable by all targeted recipients
  Exercise, // Actionable only by designated exercise participants
  System,   // For messages that support alert network internal functions
  Test,     // Technical testing only, all recipients disregard
  Draft;    // A preliminary template or draft, not actionable in its current form

  String toJson() => name;
  static Status fromJson(String json) => values.byName(json);

  /// extract the severity from the string and return the corresponding enum
  static Status fromString(String status) {
    for (Status sta in Status.values) {
      if (sta.name == status) {
        return sta;
      }
    }
    return Status.Actual; //@todo what should be the default value?
  }
}




