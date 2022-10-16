import 'package:flutter/material.dart';

class WarningSourcesDialog extends StatefulWidget {
  const WarningSourcesDialog({Key? key}) : super(key: key);

  @override
  _WarningSourcesDialog createState() => _WarningSourcesDialog();
}

class _WarningSourcesDialog extends State<WarningSourcesDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Quellen der Meldungen'),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        child: ListView(
          children: [
            ListTile(
              title: Text("Mowas (Modulares Warnsystem)"),
              subtitle: Text(
                "Bundesamt für Bevölkerungsschutz und Katastrophenhilfe - warnt vor Katastrophen",
              ),
            ),
            ListTile(
              title: Text("Biwapp (Bürger Info- & Warn-App)"),
              subtitle: Text(
                "regionales Warn- und Informationssystem vieler Kommunen - warnt z.B. vor: Bombenfund, Chemieunfall, Feuer, Hochwasser, Erdrutsch / Lawine, Großschadenslage, Unwetter, Verkehrsunfall, Unterrichtsausfall und Seuchenfall.",
              ),
            ),
            ListTile(
              title: Text("Katwarn"),
              subtitle: Text(
                "Entwickelt von der Fraunhofer-Gesellschaft - warnt z.B. bei: Großbrand, Bombenfund und Umweltkatastrophe",
              ),
            ),
            ListTile(
              title: Text("DWD (Deutscher Wetterdienst)"),
              subtitle: Text("Bundesbehörde - warnt vor Unwettern"),
            ),
            ListTile(
              title: Text("LHP (Länderübergreifendes Hochwasser Portal)"),
              subtitle:
                  Text("Eine gemeinsame Initiative der deutschen Bundesländer "
                      "- warnt vor Hochwasserwasser"),
            ),
            ListTile(
              title: Text("Alert Swiss (experimentell)"),
              subtitle: Text(
                "Warnmeldungen für die Schweiz",
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Schließen', style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }
}
