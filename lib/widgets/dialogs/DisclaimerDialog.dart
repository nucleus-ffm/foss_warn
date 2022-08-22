import 'package:flutter/material.dart';

class DisclaimerDialog extends StatefulWidget {
  const DisclaimerDialog({Key? key}) : super(key: key);

  @override
  _DisclaimerDialogState createState() => _DisclaimerDialogState();
}

class _DisclaimerDialogState extends State<DisclaimerDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Haftungsausschluss'),
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Diese App wurde in der Hoffnung erstellt, dass sie nützlich ist, kommt"
            " aber OHNE JEGLICHE GEWÄHRLEISTUNG. Der Entwickler kann zu keinem "
            "Zeitpunkt garantieren, dass die App fehlerfrei funktioniert und"
            " alle Warnungen jederzeit anzeigt. Die verwendeten Schnittstellen"
            " könnten sich jederzeit verändern, wodurch die App vorerst nicht"
          " mehr funktioniert. Auch übernimmt der Entwickler keinerlei Gewähr "
                  "für die Aktualität, Korrektheit und Vollständigkeit der angezeigten "
                  "Meldungen. Verlassen Sie sich deshalb zu KEINEM ZEITPUNKT "
          "auf diese App. Auch werden die Warnungen immer mit einer gewissen"
          " VERZÖGERUNG im Hintergrund empfangen. Diese App benutzt keinen "
          "Push-Services, sondern lädt in einem gewissen Zeitabstand die "
          "neusten Meldungen und benachrichtigt dann, wenn nötig. \n\n"
            "Mit der Benutzung von FOSS Warn stimmen Sie dem zu."),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('verstanden', style: TextStyle(color: Colors.green),),
        ),
      ],
    );
  }
}
