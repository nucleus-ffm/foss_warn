import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';
import '../../enums/sorting_categories.dart';
import '../../main.dart';

class SortByDialog extends StatefulWidget {
  const SortByDialog({super.key});

  @override
  State<SortByDialog> createState() => _SortByDialogState();
}

class _SortByDialogState extends State<SortByDialog> {
  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var theme = Theme.of(context);
    var navigator = Navigator.of(context);

    return SimpleDialog(
      title: Text(localizations.sorting_headline),
      children: [
        ListTile(
          title: Text(localizations.sorting_by_date),
          leading: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.date_range),
          ),
          selectedColor: theme.colorScheme.primary,
          selected: userPreferences.sortWarningsBy == SortingCategories.data
              ? true
              : false,
          onTap: () {
            setState(() {
              userPreferences.sortWarningsBy = SortingCategories.data;
            });

            navigator.pop();
          },
        ),
        ListTile(
          title: Text(localizations.sorting_by_warning_level),
          leading: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.warning),
          ),
          selectedColor: theme.colorScheme.primary,
          selected: userPreferences.sortWarningsBy == SortingCategories.severity
              ? true
              : false,
          onTap: () {
            setState(() {
              userPreferences.sortWarningsBy = SortingCategories.severity;
            });

            navigator.pop();
          },
        ),
        ListTile(
          title: Text(localizations.sorting_by_source),
          leading: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.source),
          ),
          selectedColor: theme.colorScheme.primary,
          selected: userPreferences.sortWarningsBy == SortingCategories.source
              ? true
              : false,
          onTap: () {
            setState(() {
              userPreferences.sortWarningsBy = SortingCategories.source;
            });

            navigator.pop();
          },
        ),
      ],
    );
  }
}
