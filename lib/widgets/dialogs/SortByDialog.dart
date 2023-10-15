import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../main.dart';
import '../../services/saveAndLoadSharedPreferences.dart';

class SortByDialog extends StatefulWidget {
  const SortByDialog({Key? key}) : super(key: key);

  @override
  _SortByDialogState createState() => _SortByDialogState();
}

class _SortByDialogState extends State<SortByDialog> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppLocalizations.of(context)!.sorting_headline),
      children: [
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.sorting_by_date,
            //style: TextStyle(fontSize: 12),
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.date_range),
          ),
          selectedColor: Theme.of(context).colorScheme.secondary,
          selected: userPreferences.sortWarningsBy == "date" ? true : false,
          onTap: () {
            setState(() {
              userPreferences.sortWarningsBy = "date";
            });
            saveSettings();
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.sorting_by_warning_level,
            //style: TextStyle(fontSize: 14),
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.warning),
          ),
          selectedColor: Theme.of(context).colorScheme.secondary,
          selected: userPreferences.sortWarningsBy == "severity" ? true : false,
          onTap: () {
            setState(() {
              userPreferences.sortWarningsBy = "severity";
            });
            saveSettings();
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.sorting_by_source,
            //style: TextStyle(fontSize: 16),
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.source),
          ),
          selectedColor: Theme.of(context).colorScheme.secondary,
          selected: userPreferences.sortWarningsBy == "source" ? true : false,
          onTap: () {
            setState(() {
              userPreferences.sortWarningsBy = "source";
            });
            saveSettings();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
