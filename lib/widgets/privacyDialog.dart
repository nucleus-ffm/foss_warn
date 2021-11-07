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
              Text("FOSS Warn versendet keine Informationen über seine Nutzung,"
                  " sondern baut nur in regelmäßigen Abständen eine Verbindung "
                  "zu https://warnung.bund.de auf und lädt von dort die neusten Warnungen."
                  "\n\n"
                  "Zusätzlich kann FOSS Warn prüfen, ob ein Update verfügbar ist. "
                  "Dafür lädt FOSS Warn Daten von Github und vergleicht lokal die Versionsnummern. "
                   "FOSS Warn prüft dabei nicht unaufgefordert im "
                  "Hintergrund auf Updates, sondern nur, wenn der Updatecheck "
                  "in den Einstellungen aufgerufen wird. "
                  "\n\n"
                  "Für den Aufruf überträgt FOSS Warn nur die technisch notwendigen Daten."
                  " Auf die Serverseitige Verarbeitung hat FOSS Warn keinen Einfluss "
                  ""
              ),
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
              ),
              Row(
                children: [
                  Icon(Icons.open_in_browser),
                  Flexible(
                    fit: FlexFit.loose,
                    child: TextButton(onPressed: () {
                      Future<void>? _launched = launchUrlInBrowser('https://docs.github.com/en/github/site-policy/github-privacy-statement');
                    }, child: Text("Zur Datenschutzerklärung von Github.com")),
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
            'verstanden',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
      backgroundColor: Colors.white,
    );
  }
}
