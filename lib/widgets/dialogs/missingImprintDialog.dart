import 'package:flutter/material.dart';

class MissingImprintDialog extends StatefulWidget {
  const MissingImprintDialog({Key? key}) : super(key: key);

  @override
  _MissingImprintDialogState createState() => _MissingImprintDialogState();
}

class _MissingImprintDialogState extends State<MissingImprintDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Impressum?'),
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  "Recherchen meinerseits konnten nicht klar beantworten, ob Software unter das TMG fällt und somit Impressumspflichtig wäre oder nicht. Die allermeisten Apps in F-Dorid besitzen KEIN Impressum - bei Desktop Anwendungen noch weniger. Wenn Sie sich auskennen und mir auf die Frage eine klare Antwort geben können, würde ich mich freuen, wenn Sie mit mir in Kontakt treten."),
              SizedBox(
                height: 10,
              ),
              Text(
                  "Diese App ist ein nicht-kommerzielles Open-Source Projekt ohne journalistische Inhalte. "),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('schließen',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        ),
      ],
    );
  }
}
