import 'package:flutter/material.dart';

class ChangeLogDialog extends StatelessWidget {
  const ChangeLogDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Änderungen'),
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("0.1.11 (beta)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              Text("* Fehler behoben wodurch bei einer neuen Installtion keine Benachrichtigungen angezeigt wurden.\n * kleine Layoutanpassungen für kleine Bildschirme."),
              Text("\n"),
              Text("0.1.10 (beta)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              Text("* Änderungensdialog hinzugefügt\n* Statusanzeige um Fehler beim Auslesen erweitert \n* doppelte Orte aus der Liste entfernt\n * Falsche Zeitangabe korrigiert \n* Breche alle Benachrichtigungen ab, wenn eine Warnung gelesen wurde (noch nicht optimal)"),
              Text("\n"),
              Text("0.1.9 (beta)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              Text("* unnötige Schalter entfernt\n* Fehler korrigiert der das parsen abgebrochen hat"),
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
