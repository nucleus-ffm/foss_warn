import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

SelectUnifiedPushDistributorDialog(List<String> distributors) {
  return (BuildContext context) {
    return SimpleDialog(
        title: const Text('Select push distributor'),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
                "Please select the UnifiedPush distributor which FOSSWarn should use."),
          ),
          ...distributors
              .map<Widget>(
                (d) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, d);
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(12), child: Text(d))),
                  ),
                ),
              )
              .toList()
        ]);
  };
}
