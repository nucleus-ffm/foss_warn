import 'package:flutter/material.dart';
import 'package:foss_warn/services/checkForMyPlacesWarnings.dart';
import 'package:foss_warn/widgets/ConnectionErrorWidget.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/getData.dart';
import '../services/listHandler.dart';
import '../widgets/WarningWidget.dart';
import '../services/saveAndLoadSharedPreferences.dart';
import '../services/sortWarnings.dart';
import '../services/updateProvider.dart';

class AllWarningsView extends StatefulWidget {
  const AllWarningsView({Key? key}) : super(key: key);

  @override
  _AllWarningsViewState createState() => _AllWarningsViewState();
}

class _AllWarningsViewState extends State<AllWarningsView> {
  var data;
  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (firstStart) {
      loading = true;
      firstStart = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> reloadData() async {
      setState(() {
        loading = true;
      });
      //
    }

    void loadData() async {
      checkForMyPlacesWarnings();
      data = await getData();
      sortWarnings();
      loadNotificationSettingsImportanceList();
      setState(() {
        loading = false;
      });
    }

    if (loading == true) {
      loadData();
    }
    while (loading) {
      // show loading screen
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
        child: warnMessageList.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      child: ConnectionError(),
                    ),
                    ...warnMessageList
                        .map((warnMessage) => WarningWidget(warnMessage: warnMessage))
                        .toList(),
                  ]
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: ConnectionError(),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Hier gibt es noch nichts zu sehen... ",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text("\n"),
                            Text(
                                "Entweder gibt es gerade keine Meldungen, \n oder Sie haben keine Internetverbindung?"),
                            SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  loading = true;
                                });
                              },
                              child: Text(
                                "Neuladen",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: TextButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.secondary),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
