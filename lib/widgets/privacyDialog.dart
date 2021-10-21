import 'package:flutter/material.dart';
import '../services/urlLauncher.dart';

class PrivacyDialog extends StatefulWidget {
  const PrivacyDialog({Key? key}) : super(key: key);

  @override
  _PrivacyDialogState createState() => _PrivacyDialogState();
}

class _PrivacyDialogState extends State<PrivacyDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Datenschutz'),
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("FOSS Warn versendet keine Informationen über seine Nutzung, sondern baut nur in regelmäßigen Abständen eine Verbindung zu https://warnung.bund.de auf und lädt von dort die neusten Warnungen. Standardmäßig baut FOSS Warn alle 15 Minuten im Hintergrund eine Verbindung auf und lädt die neusten Warnungen. Die Hintergrundaktualisierung kann in den Einstellungen deaktiviert werden."
                  "\n\n"
                  "Für den Aufruf überträgt FOSS Warn nur die technisch notwendigen Daten. Auf die Serverseitige Verarbeitung habe ich keinen Einfluss und kann nur auf die Datenschutzerklärung von warnung.bund.de verweisen. "),
              SizedBox(height: 10,),
              Row(
                children: [
                  Icon(Icons.open_in_browser),

                  Flexible(
                    fit: FlexFit.loose,
                    child: TextButton(onPressed: () {
                      Future<void>? _launched = launchUrlInBrowser('https://warnung.bund.de/datenschutz');
                    }, child: Text("Zur Datenschutzerklärung von Warnung.bund.de")),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'schließen',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
      backgroundColor: Colors.white,
    );
  }
}
