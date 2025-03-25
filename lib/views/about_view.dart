import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/widgets/dialogs/disclaimer_dialog.dart';
import '../main.dart';
import '../services/url_launcher.dart';
import '../widgets/dialogs/missing_imprint_dialog.dart';
import '../widgets/dialogs/privacy_dialog.dart';
import '../widgets/dialogs/change_log_dialog.dart';

class AboutView extends StatelessWidget {
  const AboutView({
    required this.onShowLicensePressed,
    super.key,
  });

  final VoidCallback onShowLicensePressed;

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.about_headline),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        children: [
          Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const Image(
              height: 180,
              image: AssetImage('assets/app_icon/app_icon.png'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 10, top: 5),
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
                localizations.about_summery,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: Center(
              child: Text(
                "This project is funded by NLnet.", //@todo translate
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.open_in_browser_outlined),
            title: Text(
              (localizations.about_official_source),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "https://warnung.bund.de/meldungen",
              style: theme.textTheme.bodyLarge,
            ),
            onTap: () =>
                launchUrlInBrowser('https://warnung.bund.de/meldungen'),
          ),
          ListTile(
            leading: const Icon(Icons.perm_identity_outlined),
            title: Text(
              localizations.about_author,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Nucleus",
              style: theme.textTheme.bodyLarge,
            ),
            onTap: () => launchUrlInBrowser('https://github.com/nucleus-ffm'),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(
              localizations.about_contact,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "foss-warn@posteo.de",
              style: theme.textTheme.bodyLarge,
            ),
            onTap: () => launchEmail('mailto:foss-warn@posteo.de'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_outlined),
            title: Text(
              localizations.about_imprint,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              localizations.about_imprint_subtitle,
              style: theme.textTheme.bodyLarge,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const MissingImprintDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(
              localizations.about_privacy,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              localizations.about_privacy_subtitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const PrivacyDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: Text(
              localizations.about_disclaimer,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              localizations.about_disclaimer_subtitle,
              style: theme.textTheme.bodyLarge,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const DisclaimerDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: Text(
              localizations.about_version,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${userPreferences.versionNumber} (beta)",
              style: theme.textTheme.bodyLarge,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ChangeLogDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(
              localizations.about_licence,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "GPL v3.0",
              style: theme.textTheme.bodyLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.business_center_outlined),
            title: Text(
              localizations.about_other_license,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              localizations.about_other_license_subtitle,
              style: theme.textTheme.bodyLarge,
            ),
            onTap: onShowLicensePressed,
          ),
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: Text(
              localizations.about_contributors,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              localizations.about_contributors_subtitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: () => launchUrlInBrowser(
              'https://github.com/nucleus-ffm/foss_warn/blob/main/README.md#contributors',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.code_outlined),
            title: Text(
              localizations.about_sourcecode,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              localizations.about_sourcecode_subtitle,
              style: theme.textTheme.bodyLarge,
            ),
            onTap: () =>
                launchUrlInBrowser('https://github.com/nucleus-ffm/foss_warn'),
          ),
        ],
      ),
    );
  }
}
