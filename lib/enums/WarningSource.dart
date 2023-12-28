enum WarningSource {
  alertSwiss,
  biwapp,
  dwd,
  katwarn,
  lhp,
  mowas,
  other;

  String toJson() => name;

  static WarningSource fromString(String source) {
    switch (source.toUpperCase()) {
      case "ALERT SWISS":
        return WarningSource.alertSwiss;
      case "MOWAS":
        return WarningSource.mowas;
      case "KATWARN":
        return WarningSource.katwarn;
      case "DWD":
        return WarningSource.dwd;
      case "BIWAPP":
        return WarningSource.biwapp;
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
    // default return value: index of WarningSource.other
    return 6;
  }
}
