import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/urlLauncher.dart';
import 'widgets/missingImprintDialog.dart';
import 'widgets/privacyDialog.dart';
import 'widgets/ChangeLogDialog.dart';

class AboutView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Future<void>? _launched;
    return Scaffold(
      appBar: AppBar(
        title: Text("Über diese App"),
        backgroundColor: Colors.green[700],
        systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: ListView(
        children: [
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "FOSS Warn",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                SizedBox(
                  width: 300,
                  child: Text(
                    """
Diese App ist ein Freizeit-Projekt von mir und wurde in der Hoffnung erstellt, dass sie nützlich ist. Dabei kann ich jedoch zu keinem Zeitpunkt garantieren, dass die App fehlerfrei funktioniert. Die benutzten Schnittstellen könnten sich jederzeit verändern, wodurch bis zu einem Update der App, keine Warnmeldungen mehr angezeigt werden. Verlassen Sie sich zu KEINEM Zeitpunkt auf die App. Auch kann ich nicht garantieren, dass alle vorhandenen Meldungen in der App auftauchen. 
          
Über Hinweise zur Verbesserung oder Fehlern würde ich mich freuen. Auch wenn Sie diese App einfach super finden, würde ich mich freuen, davon zu hören.""",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.open_in_browser),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Alle Meldungen von offizieller Seite:",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  "https://warnung.bund.de/meldungen",
                  style: TextStyle(color: Colors.grey[900]),
                ),
              ],
            ),
            onTap: () {
              launchUrlInBrowser('https://warnung.bund.de/meldungen');
            },
          ),
          ListTile(
            leading: Icon(Icons.perm_identity),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Autor:",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  "Nucleus",
                  style: TextStyle(color: Colors.grey[900]),
                ),
              ],
            ),
            onTap: () {
              launchUrlInBrowser('https://github.com/nucleus-ffm');
            },
          ),
          ListTile(
            leading: Icon(Icons.mail),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kontakt:",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  "foss-warn@posteo.de",
                  style: TextStyle(color: Colors.grey[900]),
                ),
              ],
            ),
            onTap: () {
              _launched = launchEmail('mailto:foss-warn@posteo.de');
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Impressum?",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  "Müsste hier ein Impressum stehen?",
                  style: TextStyle(color: Colors.grey[900]),
                ),
              ],
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MissingImprintDialog();
                },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Datenschutz",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  "alles was die App macht und nicht macht",
                  style: TextStyle(color: Colors.grey[900]),
                ),
              ],
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return PrivacyDialog();
                },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Version:",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  "0.1.12 (beta)",
                  style: TextStyle(color: Colors.grey[900]),
                ),
              ],
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ChangeLogDialog();
                },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lizenz:",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  "@todo",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.business_center_sharp),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "andere Lizenzen:",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  "FOSS Warn verwendet nützliche andere Software",
                  style: TextStyle(color: Colors.grey[900]),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LicensePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.code_rounded, ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Quellcode",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text("Bald erhältlich auf floppy, bis dahin auf GitHub", style: TextStyle(color: Colors.grey[900]),),
              ],
            ),
            onTap: () {
              _launched = launchUrlInBrowser('https://github.com/nucleus-ffm/foss_warn');
            },
          ),
          SizedBox(height: 10,)
        ],
      ),
    );
  }
}
