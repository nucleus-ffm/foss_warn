import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/widgets/dialogs/DisclaimerDialog.dart';
import 'package:foss_warn/widgets/dialogs/WarningSourcesDialog.dart';
import '../main.dart';
import '../services/urlLauncher.dart';
import '../widgets/dialogs/missingImprintDialog.dart';
import '../widgets/dialogs/privacyDialog.dart';
import '../widgets/dialogs/ChangeLogDialog.dart';

class AboutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).about_headline),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 10, bottom: 20),
        children: [
          Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image(
                height: 120,
                width: 120,
                image: AssetImage('assets/app_icon.png'),
              )),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 10),
            child: Center(
              child: Text(
                "FOSS Warn",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: Center(
              child: Text(
                AppLocalizations.of(context).about_summery,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.source_outlined),
            title: Text(
              AppLocalizations.of(context).about_source,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(AppLocalizations.of(context).about_source_subtitle,
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
              (AppLocalizations.of(context).about_official_source),
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
              (AppLocalizations.of(context).about_author),
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
              (AppLocalizations.of(context).about_contact),
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
              (AppLocalizations.of(context).about_imprint),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              AppLocalizations.of(context).about_imprint_subtitle,
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
              AppLocalizations.of(context).about_privacy,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              AppLocalizations.of(context).about_privacy_subtitle,
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
              AppLocalizations.of(context).about_disclaimer,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              AppLocalizations.of(context).about_disclaimer_subtitle,
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
              AppLocalizations.of(context).about_version,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${userPreferences.versionNumber} (beta)",
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
              AppLocalizations.of(context).about_licence,
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
              AppLocalizations.of(context).about_other_license,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              AppLocalizations.of(context).about_other_license_subtitle,
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
                AppLocalizations.of(context).about_contributors,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                AppLocalizations.of(context).about_contributors_subtitle,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () => launchUrlInBrowser(
                  'https://github.com/nucleus-ffm/foss_warn/blob/main/README.md#contributors')),
          ListTile(
            leading: Icon(Icons.code_outlined),
            title: Text(
              AppLocalizations.of(context).about_sourcecode,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              AppLocalizations.of(context).about_sourcecode_subtitle,
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
