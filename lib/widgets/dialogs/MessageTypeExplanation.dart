import 'package:flutter/material.dart';

class MessageTypeExplanation extends StatefulWidget {
  const MessageTypeExplanation({Key? key}) : super(key: key);

  @override
  _MessageTypeExplanationState createState() => _MessageTypeExplanationState();
}

class _MessageTypeExplanationState extends State<MessageTypeExplanation> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Legende '),
      content: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: const <TextSpan>[
                  TextSpan(
                      text: 'Achtung: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Neue Meldung zu einer akuten und aktuellen Bedrohung.\n\n'),
                  TextSpan(
                      text: 'Update: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Aktualisierung einer vorangegangenen Meldung.\n\n'),
                  TextSpan(
                      text: 'Entwarnung: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Entwarnung für eine vorherige Meldung.'
                      ' Meistens ist die Warnung jetzt aufgehoben.'),
                ],
              ),
            ),
          ],
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
