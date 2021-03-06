import 'package:flutter/material.dart';

class CategoryExplanation extends StatefulWidget {
  const CategoryExplanation({Key? key}) : super(key: key);

  @override
  _CategoryExplanationState createState() => _CategoryExplanationState();
}

class _CategoryExplanationState extends State<CategoryExplanation> {
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
                      text: 'Gesundheit: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Informationen bei'
                      ' gesundheitsgefährdenden Ereignissen wie z.B.'
                      ' Pandemien oder Wasserverunreinigungen\n\n'),
                  TextSpan(
                      text: 'Feuer: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Informationen bei Bränden \n \n'),
                  TextSpan(
                      text: 'Infrastruktur: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Informationen bei infrastrukturellen '
                      'Ereignissen wie z.B. einem Ausfall der Notrufleitung  \n\n'),
                  TextSpan(
                      text: 'CBRNE: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: 'Informationen bei Ereignissen mit chemischen,'
                              ' biologischen, radiologischen, nuklearen'
                              ' und explosionsgefährdeten Stoffen \n\n'),
                  TextSpan(
                      text: 'Umwelt: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Informationen bei Naturereignissen wie z.B. Sturmfluten \n\n'),

                  TextSpan(
                      text: 'Wetter: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Informationen bei Meteorologisch Ereignissen wie '
                      'z.B. Sturmböen und Hochwasser  \n\n'),

                  TextSpan(
                      text: 'Sicherheit: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Informationen bei polizeilichen Meldungen \n\n'),

                  TextSpan(
                      text: 'Sonstiges: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Informationen bei anderen Meldungen'
                      ' wie z.B. zur Geflügelpest \n\n'),
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
