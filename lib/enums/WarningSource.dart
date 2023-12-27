enum WarningSource {
  mowas,
  biwapp,
  katwarn,
  dwd,
  lhp,
  alertSwiss,
  other;

  String toJson() => name;

  static WarningSource fromString(String name) {
    switch (name.toUpperCase()) {
      case "ALERT SWISS":
        return WarningSource.alertSwiss;
      case "MOWAS":
        return WarningSource.mowas;
      case "KATWARN":
        return WarningSource.katwarn;
      case "DWD":
        return WarningSource.dwd;
      case "LHP":
        return WarningSource.lhp;
      default:
        return WarningSource.other;
    }
  }

  /// used to sort warning
  static int getIndexFromWarningSource(WarningSource source) {
    final sources = WarningSource.values;
    for (int i = 0; i < sources.length; i++) {
      if (sources[i] == source) {
        return i.toInt();
      }
    }
    return 0;
  }
}
