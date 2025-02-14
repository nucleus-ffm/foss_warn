import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';

import '../class/class_notification_service.dart';
import '../services/list_handler.dart';
import '../services/update_provider.dart';

class AddMyPlaceView extends ConsumerStatefulWidget {
  const AddMyPlaceView({super.key});

  @override
  ConsumerState<AddMyPlaceView> createState() => _AddMyPlaceViewState();
}

class _AddMyPlaceViewState extends ConsumerState<AddMyPlaceView> {
  List<Place> _allPlacesToShow = [];

  @override
  Widget build(BuildContext context) {
    var updater = ref.read(updaterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.add_new_place),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
        child: Column(
          children: [
            TextField(
              cursorColor: Theme.of(context).colorScheme.secondary,
              autofocus: true,
              style: Theme.of(context).textTheme.titleMedium,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context)!.add_new_place_place_name,
              ),
              onChanged: (text) {
                text = text.toLowerCase();
                setState(() {
                  _allPlacesToShow = allAvailablePlacesNames.where((place) {
                    var search = place.name.toLowerCase();
                    return search.contains(text);
                  }).toList();
                });
              },
            ),
            SizedBox(
              height: 15,
            ),
            Flexible(
              child: ListView(
                children: _allPlacesToShow
                    .map(
                      (place) => ListTile(
                        visualDensity:
                            VisualDensity(horizontal: 0, vertical: -4),
                        title: Text(place.name,
                            style: Theme.of(context).textTheme.titleMedium),
                        onTap: () {
                          setState(() {
                            updater.updateList(
                              alertApi: ref.read(alertApiProvider),
                              newPlace: place,
                            );
                            // cancel warning of missing places (ID: 3)
                            NotificationService.cancelOneNotification(3);
                            Navigator.of(context).pop();
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
