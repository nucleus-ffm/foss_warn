import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/services/warnings.dart';

import 'dialogs/delete_place_dialog.dart';
import 'dialogs/meta_info_for_place_dialog.dart';

class MyPlaceWidget extends ConsumerWidget {
  const MyPlaceWidget({
    required this.place,
    required this.onPressed,
    super.key,
  });

  final Place place;
  final void Function(String placeSubscriptionId) onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    var mediaQuery = MediaQuery.of(context);
    var localizations = context.localizations;

    var warnings = ref.watch(
      processedAlertsProvider.select(
        (alerts) => alerts.where(
          (alert) => alert.placeSubscriptionId == place.subscriptionId,
        ),
      ),
    );

    return Card(
      color:
          place.isExpired ? theme.colorScheme.outlineVariant : theme.cardColor,
      child: InkWell(
        onLongPress: () {
          debugPrint("DeletePlaceDialog opened");
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return DeletePlaceDialog(myPlace: place);
            },
          );
        },
        onTap: () {
          if (warnings.isNotEmpty) {
            onPressed(place.subscriptionId);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return MetaInfoForPlaceDialog(myPlace: place);
                        },
                      );
                    },
                    icon: const Icon(Icons.location_city),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    height: 60,
                    width: mediaQuery.size.width * 0.6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            place.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            localizations
                                .my_place_warnings_count(warnings.length),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              //check the number of warnings and display check or warning
              Flexible(
                child: warnings.isEmpty
                    ? TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                          foregroundColor: theme.colorScheme.onSecondary,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(15),
                        ),
                        onPressed: () {},
                        child: Icon(
                          Icons.check,
                          color: theme.colorScheme.onSecondary,
                        ),
                      )
                    : !warnings.any((warning) => !warning.read)
                        ? TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(15),
                            ),
                            onPressed: () => onPressed(place.subscriptionId),
                            child: const Icon(
                              Icons.mark_chat_read,
                              color: Colors.white,
                            ),
                          )
                        : TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(15),
                            ),
                            onPressed: () => onPressed(place.subscriptionId),
                            child: const Icon(
                              Icons.warning,
                              color: Colors.white,
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
