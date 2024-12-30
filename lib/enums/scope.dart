enum Scope {
  public, // For general dissemination to unrestricted audiences
  restricted, // For dissemination only to users with a known operational requirement (see <restriction>, below)
  private; // For dissemination only to specified addresses (see <addresses>, below)

  String toJson() => name;
  static Scope fromJson(String json) => values.byName(json);

  /// extract the severity from the string and return the corresponding enum
  static Scope fromString(String value) {
    for (Scope i in Scope.values) {
      if (i.name == value.toLowerCase()) {
        return i;
      }
    }
    return Scope.public; //@todo what should be the default value?
  }
}
