import 'package:flutter/material.dart';
import '../../services/urlLauncher.dart';

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
                  "zu warnung.bund.de auf und lädt von dort die neusten Warnungen. \n\n"
                  "Für die Liste der Ortschaften lädt FOSS Warn einmalig beim ersten Start"
                  " eine Liste von xrepository.de (betrieben von der KoSIT) herunter."
                  "\n\n"
                  "Um nur die relevanten Warnungen zu laden, verwendet FOSS Warn "
                  "eine API bei der der ausgewählte Ort als Geocode mitgesendet wird. "
                  "Für den Betreiber der API ist also sichtbar, welche Orte"
                  " (auf Kreisebene) Sie hinterlegt haben."
                  "\n\n"
                  "Für den Aufruf überträgt FOSS Warn nur die technisch notwendigen Daten."
                  " Auf die serverseitige Verarbeitung hat FOSS Warn keinen Einfluss."
                  ""),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(Icons.open_in_browser),
                  Flexible(
                    fit: FlexFit.loose,
                    child: TextButton(
                        onPressed: () => launchUrlInBrowser(
                            'https://warnung.bund.de/datenschutz'),
                        child: Text(
                            "Zur Datenschutzerklärung von Warnung.bund.de")),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.open_in_browser),
                  Flexible(
                    fit: FlexFit.loose,
                    child: TextButton(
                        onPressed: () => launchUrlInBrowser(
                            'https://www.xrepository.de/cms/datenschutz.html'),
                        child: Text(
                            "Zur Datenschutzerklärung von xrepository.de")),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.open_in_browser),
                  Flexible(
                    fit: FlexFit.loose,
                    child: TextButton(
                        onPressed: () => launchUrlInBrowser(
                            'https://docs.github.com/en/github/site-policy/github-privacy-statement'),
                        child: Text("Zur Datenschutzerklärung von Github.com")),
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
    );
  }
}
