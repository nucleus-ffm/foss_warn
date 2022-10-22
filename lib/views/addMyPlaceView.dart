import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foss_warn/services/listHandler.dart';
import 'package:provider/provider.dart';
import '../services/updateProvider.dart';



class AddMyPlaceView extends StatefulWidget {
  const AddMyPlaceView({Key? key}) : super(key: key);

  @override
  State<AddMyPlaceView> createState() => _AddMyPlaceViewState();
}

class _AddMyPlaceViewState extends State<AddMyPlaceView> {
  String newPlaceName = "";
  List<String> allPlacesToShow = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Ort hinzufügen"),
        backgroundColor: Colors.green[700],
        systemOverlayStyle:
        SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                cursorColor: Theme.of(context).colorScheme.secondary,

                autofocus: true,
                decoration: new InputDecoration(
                  labelText: 'Ortsname oder Kreisname',
                  labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                onChanged: (text) {
                  newPlaceName = text;
                  text = text.toLowerCase();
                  setState(() {
                    allPlacesToShow = allAvailablePlacesNames.where((place) {
                      var search = place.toLowerCase();
                      return search.contains(text);
                    }).toList();
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height,
                child: ListView(
                  children: allPlacesToShow
                      .map(
                        (place) => ListTile(
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                      title: Text(place),
                      onTap: () {
                        setState(() {
                          final updater =
                          Provider.of<Update>(context, listen: false);
                          updater.updateList(place);
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
      ),
    );
  }
}
