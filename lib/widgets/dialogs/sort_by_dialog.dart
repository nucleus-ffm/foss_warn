import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/extensions/context.dart';
import '../../enums/sorting_categories.dart';

class SortByDialog extends ConsumerStatefulWidget {
  const SortByDialog({super.key});

  @override
  ConsumerState<SortByDialog> createState() => _SortByDialogState();
}

class _SortByDialogState extends ConsumerState<SortByDialog> {
  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var theme = Theme.of(context);
    var navigator = Navigator.of(context);

    var userPreferences = ref.watch(userPreferencesProvider);
    var userPreferencesService = ref.read(userPreferencesProvider.notifier);

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
            userPreferencesService.setSortWarningsBy(SortingCategories.data);
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
            userPreferencesService
                .setSortWarningsBy(SortingCategories.severity);
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
            userPreferencesService.setSortWarningsBy(SortingCategories.source);
            navigator.pop();
          },
        ),
      ],
    );
  }
}
