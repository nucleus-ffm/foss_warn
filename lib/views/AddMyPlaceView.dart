import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../class/abstract_Place.dart';
import '../class/class_NotificationService.dart';
import '../services/listHandler.dart';
import '../services/updateProvider.dart';

class AddMyPlaceView extends StatefulWidget {
  const AddMyPlaceView({Key? key}) : super(key: key);

  @override
  State<AddMyPlaceView> createState() => _AddMyPlaceViewState();
}

class _AddMyPlaceViewState extends State<AddMyPlaceView> {
  List<Place> _allPlacesToShow = [];

  @override
  Widget build(BuildContext context) {
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
              decoration: new InputDecoration(
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
                        title: Text(place.name, style: Theme.of(context).textTheme.titleMedium),
                        onTap: () {
                          setState(() {
                            final updater =
                                Provider.of<Update>(context, listen: false);
                            updater.updateList(place);
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
