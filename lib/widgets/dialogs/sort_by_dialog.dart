import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../enums/sorting_categories.dart';
import '../../main.dart';
import '../../services/save_and_load_shared_preferences.dart';

class SortByDialog extends StatefulWidget {
  const SortByDialog({super.key});

  @override
  State<SortByDialog> createState() => _SortByDialogState();
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
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.date_range),
          ),
          selectedColor: Theme.of(context).colorScheme.primary,
          selected: userPreferences.sortWarningsBy == SortingCategories.data
              ? true
              : false,
          onTap: () {
            setState(() {
              userPreferences.sortWarningsBy = SortingCategories.data;
            });

            Navigator.of(context).pop();
          },
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.sorting_by_warning_level,
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.warning),
          ),
          selectedColor: Theme.of(context).colorScheme.primary,
          selected: userPreferences.sortWarningsBy == SortingCategories.severity
              ? true
              : false,
          onTap: () {
            setState(() {
              userPreferences.sortWarningsBy = SortingCategories.severity;
            });
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.sorting_by_source,
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.source),
          ),
          selectedColor: Theme.of(context).colorScheme.primary,
          selected: userPreferences.sortWarningsBy == SortingCategories.source
              ? true
              : false,
          onTap: () {
            setState(() {
              userPreferences.sortWarningsBy = SortingCategories.source;
            });
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
