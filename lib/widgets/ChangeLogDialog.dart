import 'package:flutter/material.dart';

class ChangeLogDialog extends StatelessWidget {
  const ChangeLogDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Änderungsprotokoll'),
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "0.1.13 (beta)",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text("* Bei Meldungen wird nun auch der Herausgeber der Warnung angezeigt\n" +
                  "* unwichtige Tags können jetzt ausgeblendet werden\n" +
                  "* Warnungen können jetzt geteilt werden \n" +
                  "* Warnungen können jetzt auch mit einem Tip auf die Warnung geöffnet werden\n"
                      "* Der Zeilenabstand bei der Liste der verfügbaren Orte wurde verringert"),
              Text("\n"),
              Text(
                "0.1.12 (beta)",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                  "* Tippfehler verbessert \n* Möglichkeit zum Einstellen des Startbildschirms ergänzt \n* gleiche Benachrichtigungen werden jetzt nur einmal angezeigt \n* Benachrichtigungen werden jetzt richtig gruppiert  \n* Ort können jetzt auch mit dem Tippen auf den Ortsnamen geöffnet werden."),
              Text(
                  "* Fehler mit doppelt angezeigten Warnungen bei 'meinen Orten' behoben \n * Pull to refresh bei 'Meine Orte' ergänzt \n* Benachrichtigungen werden jetzt abgebrochen, wenn die Warnung gelesen wurde - bei mehreren Warnungen für einen Ort durch die letzte Warnung in der Liste."),
              Text("\n"),
              Text(
                "0.1.11 (beta)",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                  "* Fehler behoben wodurch bei einer neuen Installation keine Benachrichtigungen angezeigt wurden.\n * kleine Layoutoptimierung für kleine Bildschirme."),
              Text("\n"),
              Text(
                "0.1.10 (beta)",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                  "* Änderungsprotokoll hinzugefügt\n* Statusanzeige um Fehler beim Auslesen erweitert \n* doppelte Orte aus der Liste entfernt\n * Falsche Zeitangabe korrigiert \n* Breche alle Benachrichtigungen ab, wenn eine Warnung gelesen wurde (noch nicht optimal)"),
              Text("\n"),
              Text(
                "0.1.9 (beta)",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                  "* unnötige Schalter entfernt\n* Fehler korrigiert der das parsen abgebrochen hat"),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        new TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('schließen'),
        )
      ],
      backgroundColor: Colors.white,
    );
  }
}
