import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:unifiedpush/unifiedpush.dart';
import '../../class/class_unified_push_handler.dart';
import '../../services/subscription_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangeUnifiedPushDistributorDialog extends ConsumerStatefulWidget {
  const ChangeUnifiedPushDistributorDialog({super.key});

  @override
  ConsumerState<ChangeUnifiedPushDistributorDialog> createState() =>
      _ChangeUnifiedPushDistributorDialogState();
}

class _ChangeUnifiedPushDistributorDialogState
    extends ConsumerState<ChangeUnifiedPushDistributorDialog> {
  /// register with the selected distributor for push notifications
  Future<void> registerDistributor(String picked, WidgetRef ref) async {
    UserPreferences userPreferences = ref.read(userPreferencesProvider);
    await UnifiedPush.saveDistributor(picked);
    // register your app to the distributor
    try {
      await UnifiedPush.register(
        instance: UserPreferences.unifiedPushInstance,
        vapid: userPreferences.webPushVapidKey,
      );
    } on MissingPluginException catch (e) {
      debugPrint("error while registering UnifiedPush: $e");
      return;
    }
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
            ...distributors.map<Widget>(
              (d) => Padding(
                padding: const EdgeInsets.all(3.0),
                child: ListTile(
                  title: Text("${d["name"]} (${d["distributor"]})"),
                  leading: const Icon(Icons.public),
                  onTap: () async {
                    // register distributor is one is selected, otherwise do nothing
                    if (d["distributor"] != null) {
                      UserPreferencesService userPreferencesService =
                          ref.read(userPreferencesProvider.notifier);
                      userPreferencesService.setUnifiedPushRegistered(false);
                      UserPreferences userPreferences =
                          ref.watch(userPreferencesProvider);

                      await registerDistributor(d["distributor"]!, ref);

                      // wait until the registration is finished we have a new endpoint
                      await Future.doWhile(() async {
                        await Future.delayed(const Duration(microseconds: 1));
                        userPreferences = ref.read(userPreferencesProvider);
                        return !userPreferences.unifiedPushRegistered;
                      }).timeout(
                        const Duration(seconds: 20),
                        onTimeout: () {
                          debugPrint(
                            "Timeout waiting for unifiedPushRegistered to be set to true.",
                          );
                          return;
                        },
                      );
                    }

                    if (!mounted) {
                      return;
                    }

                    //@TODO we have to wait until the push notification configuration is finished

                    // resubscribe for all subscription
                    await resubscribeForAllArea(context, ref);

                    if (!mounted) {
                      return;
                    }
                    Navigator.pop(context, d["distributor"]);
                  },
                ),
              ),
            ),
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
