enum ResponseType {
  shelter, // Take shelter in place or per <instruction>
  evacuate, // Relocate as instructed in the <instruction>
  prepare, // Make preparations per the <instruction>
  execute, // Execute a pre-planned activity identified in <instruction>
  avoid, // Avoid the subject event as per the <instruction>
  monitor, // Attend to information sources as described in <instruction>
  // assess, // Evaluate the information in this  message. (This value SHOULD NOT beused in public warning applications.)
  allClear, // The subject event no longer poses a threat or concern and any followon action is described in <instruction>
  none; // No action recommended

  String toJson() => name;
  static ResponseType fromJson(String json) => values.byName(json);

  /// extract the severity from the string and return the corresponding enum
  static ResponseType fromString(String responseType) {
    for (ResponseType value in ResponseType.values) {
      if (value.name.toLowerCase() == responseType.toLowerCase()) {
        return value;
      }
    }
    return ResponseType.none; //@todo what should be the default value?
  }
}
