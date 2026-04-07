import 'package:flutter/material.dart';

class MatterSetupScreen extends StatelessWidget {
  const MatterSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 200.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage("assets/fosswarn_home/fosswarnhome.png"),
                ),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 3,
              child: ListView(
                children: [
                  ListTile(
                    title: Text(
                      "1. Öffne Deine SmartHome app (HomeAssistant, Alexa, etc.)",
                      // "1. Open your smartHome app (HomeAssistant, Alexa, etc.)"
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "2. Öffne die Einstellung um neue Geräte hinzuzufügen.",
                      // "2. Find the setting to add a new device",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "3. Wähle als Gerätetyp 'Matter' aus",
                      // "3. Select add Matter Device",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "4. Scan den QR code und verbinde das Gerät.",
                      // "4. Scan the QR code and connect device",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "5. Erstelle Deine Routinen wie Du möchtest.",
                      // "5. Setup your routines as you like.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
