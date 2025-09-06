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
      case "ALERTSWISS":
      case "ALERT SWISS":
        return WarningSource.alertSwiss;
      case "BIWAPP":
        return WarningSource.biwapp;
      case "DWD":
        return WarningSource.dwd;
      case "KATWARN":
        return WarningSource.katwarn;
      case "LHP":
        return WarningSource.lhp;
      case "MOWAS":
        return WarningSource.mowas;
      default:
        return WarningSource.other;
    }
  }

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
