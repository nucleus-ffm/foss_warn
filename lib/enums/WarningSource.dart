enum WarningSource {
  mowas,
  biwapp,
  katwarn,
  dwd,
  lhp,
  alertSwiss,
  other;

  String toJson() => name;
  static WarningSource fromJson(String json) => values.byName(json);

  static WarningSource fromString(String name) {
    switch (name) {
      case "Alert Swiss": return WarningSource.alertSwiss;
      case "mowas" : return WarningSource.mowas;
      case "katwarn": return WarningSource.katwarn;
      case "dwd": return WarningSource.dwd;
      case "lhp": return WarningSource.lhp;
      default: return WarningSource.other;
    }
  }
}