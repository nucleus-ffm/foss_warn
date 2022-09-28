import 'package:flutter/material.dart';

class NoWarningsInList extends StatelessWidget {
  const NoWarningsInList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.8,
      child: Column(
        // else show a screen with
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Hier gibt es nichts zu sehen",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold)),
                  Icon(
                    Icons.cloud,
                    size: 200,
                    color: Colors.green,
                  ),
                  Text(
                      "FOSS Warn hat gerade nichts zum Anzeigen.\n "),
                  SizedBox(height: 10),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
