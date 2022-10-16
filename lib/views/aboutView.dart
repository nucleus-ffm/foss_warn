import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foss_warn/widgets/dialogs/DisclaimerDialog.dart';
import 'package:foss_warn/widgets/dialogs/WarningSourcesDialog.dart';
import '../services/urlLauncher.dart';
import '../widgets/dialogs/missingImprintDialog.dart';
import '../widgets/dialogs/privacyDialog.dart';
import '../widgets/dialogs/ChangeLogDialog.dart';
import 'SettingsView.dart';

class AboutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Über diese App"),
        backgroundColor: Colors.green[700],
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 10, bottom: 20),
        children: [
          ListTile(
            title: Text(
              "FOSS Warn",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Diese App ist ein Freizeit-Projekt und wurde in "
                "der Hoffnung erstellt, "
                "dass sie nützlich ist. Hinweise zur Verbesserung "
                "oder Fehlern sind gern gesehen. "
                "Wenn Sie diese App als nützlich und gut ansehen, "
                "würde ich mich freuen, davon zu hören."),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.source_outlined),
            title: Text(
              "Quellen",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Verwendete Quellen für das Abrufen der Meldungen",
                style: Theme.of(context).textTheme.bodyText1),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => WarningSourcesDialog(),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.open_in_browser_outlined),
            title: Text(
              "Offizielle Meldungsseite",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text("https://warnung.bund.de/meldungen",
                style: Theme.of(context).textTheme.bodyText1),
            onTap: () =>
                launchUrlInBrowser('https://warnung.bund.de/meldungen'),
          ),
          ListTile(
            leading: Icon(Icons.perm_identity_outlined),
            title: Text(
              "Autor",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Nucleus",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () => launchUrlInBrowser('https://github.com/nucleus-ffm'),
          ),
          ListTile(
            leading: Icon(Icons.mail_outline),
            title: Text(
              "Kontakt",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "foss-warn@posteo.de",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () => launchEmail('mailto:foss-warn@posteo.de'),
          ),
          ListTile(
            leading: Icon(Icons.account_balance_outlined),
            title: Text(
              "Impressum?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Müsste hier ein Impressum stehen?",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => MissingImprintDialog(),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text(
              "Datenschutz",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Alles, was die App macht und nicht macht",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => PrivacyDialog(),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.article_outlined),
            title: Text(
              "Haftungsausschluss",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Was FOSS Warn nicht leisten kann",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => DisclaimerDialog(),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.star_outline),
            title: Text(
              "Version",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "$versionNumber (beta)",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => ChangeLogDialog(),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(
              "Lizenz",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "GPL v3.0",
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          ListTile(
            leading: Icon(Icons.business_center_outlined),
            title: Text(
              "Andere Lizenzen",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "FOSS Warn verwendet nützliche andere Software",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LicensePage()),
              );
            },
          ),
          ListTile(
              leading: Icon(Icons.group_outlined),
              title: Text(
                "Mitwirkende",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Menschen, die zu FOSS Warn beigetragen haben",
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () => launchUrlInBrowser(
                  'https://github.com/nucleus-ffm/foss_warn/blob/main/README.md#contributors')),
          ListTile(
            leading: Icon(Icons.code_outlined),
            title: Text(
              "Quellcode",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Bald erhältlich auf floppy, bis dahin auf GitHub",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () =>
                launchUrlInBrowser('https://github.com/nucleus-ffm/foss_warn'),
          ),
        ],
      ),
    );
  }
}
