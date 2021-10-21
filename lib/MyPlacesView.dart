import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/MyPlaceCard.dart';
import 'widgets/AddPlaceWidget.dart';

import 'services/updateProvider.dart';
import 'services/listHandler.dart';
import 'services/saveAndLoadSharedPreferences.dart';
import 'services/GetData.dart';

class MyPlaces extends StatefulWidget {
  const MyPlaces({Key? key}) : super(key: key);

  @override
  _MyPlacesState createState() => _MyPlacesState();
}

class _MyPlacesState extends State<MyPlaces> {
  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //load();
    if(myPlaceList.isEmpty) {
      loading = true;
    }
  }

  load() async {
    await loadMyPlacesList();
    await getData();
    setState(() {
      loading = false;
    });
    /*final updater =
    Provider.of<Update>(context, listen: false);
    updater.updateReadStatusInList();*/
  }


  @override
  Widget build(BuildContext context) {
    if (loading == true) {
      load();
    }
    while (loading) {
      return Center(
        child: SizedBox(
          height: 70,
          width: 70,
          child: CircularProgressIndicator(
            strokeWidth: 4,
          ),
        ),
      );
    }

    return Consumer<Update>(
      builder: (context, counter, child) => Stack(
        fit: StackFit.expand,
        children: [
          //check if myPlaceList is empty, if not show list else show text
          myPlaceList.isNotEmpty
              ? SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 65),
                      child: Column(
                        children: myPlaceList
                            .map((place) => MyPlaceCard(myPlace: place))
                            .toList(),
                      )),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Es sind noch keine Orte hinterlegt...",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Drücke auf das Plus um eigene Orte hinzuzufügen."),
                  ],
                ),

          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AddPlaceWidget();
                      },
                    );
                  },
                );
              },
            ),
          ),
          //Positioned(child: Text("Hallo Welt"))
        ],
      ),
    );
  }
}
