enum Status {
  actual, // Actionable by all targeted recipients
  exercise, // Actionable only by designated exercise participants
  system, // For messages that support alert network internal functions
  test, // Technical testing only, all recipients disregard
  draft; // A preliminary template or draft, not actionable in its current form

  String toJson() => name;
  static Status fromJson(String json) => values.byName(json.toLowerCase());

  /// extract the severity from the string and return the corresponding enum
  static Status fromString(String status) {
    for (Status sta in Status.values) {
      if (sta.name == status.toLowerCase()) {
        return sta;
      }
    }
    return Status.actual; //@todo what should be the default value?
  }
}
