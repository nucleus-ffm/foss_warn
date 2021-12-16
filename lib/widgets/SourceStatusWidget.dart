import 'package:flutter/material.dart';
import '../main.dart';

class StatusWidget extends StatelessWidget {
  const StatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Statusanzeige'),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Quellen Status:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 130, child: Text("Mowas: ")),
                SizedBox(
                    width: 30,
                    child: mowasStatus
                        ? mowasParseStatus
                            ? Icon(
                                Icons.check_box,
                                color: Colors.green,
                              )
                            : Icon(
                                Icons.speaker_notes_off_outlined,
                                color: Colors.red,
                              )
                        : Icon(
                            Icons.error,
                            color: Colors.red,
                          )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 130, child: Text("Katwarn: ")),
                SizedBox(
                    width: 30,
                    child: katwarnStatus
                        ? katwarnParseStatus
                            ? Icon(
                                Icons.check_box,
                                color: Colors.green,
                              )
                            : Icon(
                                Icons.speaker_notes_off_outlined,
                                color: Colors.red,
                              )
                        : Icon(Icons.error, color: Colors.red)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 130, child: Text("Biwapp: ")),
                SizedBox(
                    width: 30,
                    child: biwappStatus
                        ? biwappParseStatus
                            ? Icon(
                                Icons.check_box,
                                color: Colors.green,
                              )
                            : Icon(
                                Icons.speaker_notes_off_outlined,
                                color: Colors.red,
                              )
                        : Icon(Icons.error, color: Colors.red)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 130, child: Text("DWD: ")),
                SizedBox(
                    width: 30,
                    child: dwdStatus
                        ? dwdParseStatus
                            ? Icon(
                                Icons.check_box,
                                color: Colors.green,
                              )
                            : Icon(
                                Icons.speaker_notes_off_outlined,
                                color: Colors.red,
                              )
                        : Icon(Icons.error, color: Colors.red)),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 30, child: Icon(Icons.error, color: Colors.red)),
                SizedBox(
                  width: 140,
                  child: Text(
                    " = Server nicht erreichbar",
                    style: TextStyle(fontSize: 12),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 30,
                    child: Icon(Icons.speaker_notes_off_outlined,
                        color: Colors.red)),
                SizedBox(
                  width: 140,
                  child: Text(
                    " = Fehler beim Auslesen",
                    style: TextStyle(fontSize: 12),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  child: Icon(
                    Icons.check_box,
                    color: Colors.green,
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: Text(
                    " = alles ok",
                    style: TextStyle(fontSize: 12),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Anzahl der Meldungen:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 130, child: Text("Mowas:")),
                SizedBox(width: 30, child: Text(mowasMessages.toString())),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 130, child: Text("Katwarn: ")),
                SizedBox(width: 30, child: Text(katwarnMessages.toString())),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 130, child: Text("Biwapp:")),
                SizedBox(width: 30, child: Text(biwappMessages.toString())),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 130, child: Text("DWD:")),
                SizedBox(width: 30, child: Text(dwdMessages.toString())),
              ],
            ),
          ],
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
    );
  }
}
