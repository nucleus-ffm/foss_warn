enum ResponseType {
  /// Take shelter in place or per `<instruction>`
  shelter,

  /// Relocate as instructed in the `<instruction>`
  evacuate,

  /// Make preparations per the `<instruction>`
  prepare,

  /// Execute a pre-planned activity identified in `<instruction>`
  execute,

  /// Avoid the subject event as per the `<instruction>`
  avoid,

  /// Attend to information sources as described in `<instruction>`
  monitor,

  /// Evaluate the information in this  message. (This value SHOULD NOT be used in public warning applications.)
  //assess,

  /// The subject event no longer poses a threat or concern and any follow action is described in `<instruction>`
  allClear,

  /// No action recommended
  none,

  /// Fallback value if the value in the alert is valid
  unknown;

  String toJson() => name;
  static ResponseType fromJson(String? json) {
    try {
      return values.byName(json!.toLowerCase());
    } catch (e) {
      return unknown;
    }
  }

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
