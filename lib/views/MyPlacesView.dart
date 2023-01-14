import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:foss_warn/services/apiHandler.dart';

import 'package:provider/provider.dart';

import '../widgets/MyPlaceWidget.dart';


import '../services/updateProvider.dart';
import '../services/listHandler.dart';
import '../services/saveAndLoadSharedPreferences.dart';
// import '../services/getData.dart';
import '../widgets/ConnectionErrorWidget.dart';
import 'addMyPlaceView.dart';

class MyPlaces extends StatefulWidget {
  const MyPlaces({Key? key}) : super(key: key);

  @override
  _MyPlacesState createState() => _MyPlacesState();
}

class _MyPlacesState extends State<MyPlaces> {
  bool loading = false;
  @override
  void initState() {
    super.initState();
    if (myPlaceList.isEmpty) {
      loading = true;
    }
  }

  /// load data and call the API function
  load() async {
    await loadMyPlacesList();
    await callAPI();
    setState(() {
      loading = false;
    });
    /*final updater =
    Provider.of<Update>(context, listen: false);
    updater.updateReadStatusInList();*/
  }

  Future<void> reloadData() async {
    setState(() {
      loading = true;
    });
    //await Future.delayed(Duration(seconds: 2));
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
            color: Theme.of(context).colorScheme.secondary,
            strokeWidth: 4,
          ),
        ),
      );
    }

    return Consumer<Update>(
      builder: (context, counter, child) => RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: reloadData,
        child: Stack(
          fit: StackFit.expand,
          children: [
            //check if myPlaceList is empty, if not show list else show text
            myPlaceList.isNotEmpty
                ? SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 65),
                      child: Column(
                        children: [
                          Container(
                            child: ConnectionError(),
                          ),
                        ...myPlaceList
                            .map((place) => MyPlaceWidget(myPlace: place))
                            .toList(),
                            ]
                      )),
                )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context).my_place_no_place_added
                        ,
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(AppLocalizations.of(context).my_place_no_place_added_text,
                        textAlign: TextAlign.center,),
                    ],
                  ),

            Positioned(
              bottom: 10,
              right: 10,
              child: FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddMyPlaceView()),
                  );
                },
              ),
            ),
            //Positioned(child: Text("Hallo Welt"))
          ],
        ),
      ),
    );
  }
}
