class WelcomeScreenItem {
  const WelcomeScreenItem(
      {required this.title,
      required this.description,
      required this.imagePath,
      this.action});

  final String title;
  final String description;
  final String imagePath;
  final String? action;
}

List<WelcomeScreenItem> welcomeScreenItems = List.unmodifiable([
  const WelcomeScreenItem(
      title: "FOSS Warn",
      description:
          "Schön, dass Sie FOSS Warn verwenden möchten. Wischen Sie, um mit der Einführung zu beginnen.",
      imagePath: "assets/app_icon.png"),
  const WelcomeScreenItem(
      title: "Wichtig",
      description:
          "Bitte lesen Sie vor der Nutzung den Haftungsausschluss durch. Mit der Benutzung der App stimmen Sie diesem zu.",
      imagePath: "assets/paragraph.png",
      action: "disclaimer"),
  const WelcomeScreenItem(
      title: "Akkuoptimierung",
      description:
          "Damit FOSS Warn Ihnen zuverlässig Hintergrundbenachrichtigungen senden kann, sollte die Akkuoptimierung für FOSS Warn deaktiviert werden.",
      imagePath: "assets/battery.png",
      action: "batteryOptimization"),
  const WelcomeScreenItem(
      title: "Meine Orte",
      description:
          "In der App haben Sie die Möglichkeit, Orte zu hinterlegen, für die Sie Benachrichtigungen erhalten möchten. Der Abgleich, ob Warnungen für diesen Ort vorliegen, findet lokal statt. Sollte Ihr Ort nicht aufgeführt sein, können Sie es mit Ihrem Kreis oder dem nächsten größeren Ort versuchen. Wenn Sie lange auf einen hinterlegten Ort tippen, können Sie diesen wieder löschen.",
      imagePath: "assets/location.png"),
  const WelcomeScreenItem(
      title: "Warnstufen",
      description:
          "Alle Warnungen haben eine vom Herausgeber bestimmte Warn- bzw. Wichtigkeitsstufe. In den Einstellungen können Sie einstellen, für welche der vier Stufen Sie Benachrichtigungen erhalten möchten. Standardmäßig werden Sie bei Meldungen von 'geringer' Wichtigkeit nicht benachrichtigt. In der App selbst werden immer alle Meldungen angezeigt.",
      imagePath: "assets/steps.png"),
  const WelcomeScreenItem(
      title: "Los geht's!",
      description:
          "Wenn Sie diese App nützlich finden, lassen Sie es mich gerne wissen ☺️",
      imagePath: "assets/check.png")
]);
