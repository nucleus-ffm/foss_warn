import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/class/class_NotificationService.dart';
import 'package:foss_warn/services/listHandler.dart';
import 'package:provider/provider.dart';
import '../class/abstract_Place.dart';
import '../services/updateProvider.dart';

class AddMyPlaceView extends StatefulWidget {
  const AddMyPlaceView({Key? key}) : super(key: key);

  @override
  State<AddMyPlaceView> createState() => _AddMyPlaceViewState();
}

class _AddMyPlaceViewState extends State<AddMyPlaceView> {
  String newPlaceName = "";
  List<Place> allPlacesToShow = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).add_new_place),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
        child: Column(
          children: [
            TextField(
              cursorColor: Theme.of(context).colorScheme.secondary,
              autofocus: true,
              decoration: new InputDecoration(
                labelText: AppLocalizations.of(context).add_new_place_place_name,
                labelStyle:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              onChanged: (text) {
                newPlaceName = text;
                text = text.toLowerCase();
                setState(() {
                  allPlacesToShow = allAvailablePlacesNames.where((place) {
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
              //height: MediaQuery.of(context).size.height,
              //height: 100,
              child: ListView(
                children: allPlacesToShow
                    .map(
                      (place) => ListTile(
                        visualDensity:
                            VisualDensity(horizontal: 0, vertical: -4),
                        title: Text(place.getName())  ,
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
