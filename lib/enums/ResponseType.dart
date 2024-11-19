enum ResponseType {
  Shelter,  // Take shelter in place or per <instruction>
  Evacuate, // Relocate as instructed in the <instruction>
  Prepare,  // Make preparations per the <instruction>
  Execute,  // Execute a pre-planned activity identified in <instruction>
  Avoid,    // Avoid the subject event as per the <instruction>
  Monitor,  // Attend to information sources as described in <instruction>
  //Assess, // Evaluate the information in this  message. (This value SHOULD NOT beused in public warning applications.)
  AllClear, // The subject event no longer poses a threat or concern and any followon action is described in <instruction>
  None;     // No action recommended

  String toJson() => name;
  static ResponseType fromJson(String json) => values.byName(json);

  /// extract the severity from the string and return the corresponding enum
  static ResponseType fromString(String responseType) {
    for (ResponseType value in ResponseType.values) {
      if (value.name == responseType) {
        return value;
      }
    }
    return ResponseType.None; //@todo what should be the default value?
  }
}
