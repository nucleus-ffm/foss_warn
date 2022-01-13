import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../services/updateProvider.dart';
import 'package:provider/provider.dart';
import '../services/allPlacesList.dart';

class AddPlaceWidget extends StatefulWidget {
  const AddPlaceWidget({Key? key}) : super(key: key);

  @override
  _AddPlaceWidgetState createState() => _AddPlaceWidgetState();
}

class _AddPlaceWidgetState extends State<AddPlaceWidget> {
  String newPlaceName = "";

  List<String> allPlacesToShow = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allPlacesToShow = allPlaces;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return AlertDialog(
      title: Text('Ort/Kreis hinzufügen'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: new InputDecoration(
                labelText: 'Ortsname oder Kreisname',
              ),
              onChanged: (text) {
                newPlaceName = text;
                text = text.toLowerCase();
                setState(() {
                  allPlacesToShow = allPlaces.where((place) {
                    var search = place.toLowerCase();
                    return search.contains(text);
                  }).toList();
                });
              },
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Die folgende Liste könnte Fehlerhaft sein, wodurch es zu keiner Warnung kommt. Wenn Fehler auffallen, bitte Bescheid geben.",
              style: TextStyle(fontSize: 10),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              height: 150,
              width: 300,
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
            /*SizedBox(
              height: 10,
            ),*/
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Abbrechen',
            style: TextStyle(color: Colors.red),
          ),
        ),
        /*new TextButton(
          onPressed: () {
            //add new Place to List and save List
            final updater = Provider.of<Update>(context, listen: false);
            updater.updateList(newPlaceName);
            Navigator.of(context).pop();
          },
          child: Text(
            'Ok',
            style: TextStyle(color: Colors.green),
          ),
        )*/
      ],
      //backgroundColor: Colors.white,
    );
  }
}
