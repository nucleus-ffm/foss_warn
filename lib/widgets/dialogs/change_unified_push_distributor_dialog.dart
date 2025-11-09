import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/extensions/context.dart';
import '../../class/class_unified_push_handler.dart';
import '../../services/subscription_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'loading_screen.dart';

class ChangeUnifiedPushDistributorDialog extends ConsumerStatefulWidget {
  const ChangeUnifiedPushDistributorDialog({super.key});

  @override
  ConsumerState<ChangeUnifiedPushDistributorDialog> createState() =>
      _ChangeUnifiedPushDistributorDialogState();
}

class _ChangeUnifiedPushDistributorDialogState
    extends ConsumerState<ChangeUnifiedPushDistributorDialog> {
  /// handle the onTap call for every distributorListTile
  /// changes the distributor
  Future<void> onDistributorTapped(Map<String, String> d) async {
    var localizations = context.localizations;
    LoadingScreen.instance().show(
      context: context,
      text: localizations
          .change_unified_push_distributor_dialog_loading_screen_change_distributor,
    );
    // register distributor if one is selected, otherwise do nothing
    if (d["distributor"] != null) {
      UnifiedPushHandler unifiedPushHandler =
          ref.watch(unifiedPushHandlerProvider);

      try {
        await unifiedPushHandler.changeDistributor(d["distributor"]!, ref);
      } on UnifiedPushRegistrationTimeoutError {
        if (!mounted) {
          return;
        }
        LoadingScreen.instance().showResult(
          text: localizations
              .change_unified_push_distributor_dialog_loading_screen_timeout_error,
        );
        debugPrint(
          "[changeUnifiedPushDistributor] UnifiedPush registration failed",
        );

        Navigator.pop(context);
        return;
      }
    }

    if (!mounted) {
      return;
    }

    // resubscribe for all subscription
    await resubscribeForAllArea(context, ref);

    if (!mounted) {
      return;
    }
    Navigator.pop(context, d["distributor"]);
  }

  /// build the selection ListTiles
  Widget buildSelection(
    List<Map<String, String>> distributors,
    AppLocalizations localizations,
  ) {
    return SimpleDialog(
      title: Text(localizations.change_unified_push_distributor_dialog_title),
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                localizations.change_unified_push_distributor_dialog_body,
              ),
            ),
            ...distributors.isNotEmpty
                ? distributors.map<Widget>(
                    (d) => Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: ListTile(
                        title: Text("${d["name"]} (${d["distributor"]})"),
                        leading: const Icon(Icons.public),
                        onTap: () => onDistributorTapped(d),
                      ),
                    ),
                  )
                : [
                    Text(
                      localizations
                          .change_unified_push_distributor_dialog_body_no_distributor_found,
                    ),
                  ],
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var unifiedPushHandler = ref.read(unifiedPushHandlerProvider);

    return FutureBuilder<List<Map<String, String>>>(
      future: unifiedPushHandler.getListOfDistributors(),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Map<String, String>>> snapshot,
      ) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        } else {
          return buildSelection(snapshot.data!, localizations);
        }
      },
    );
  }
}
