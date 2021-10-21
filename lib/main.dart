import 'package:flutter/material.dart';
import 'package:foss_warn/widgets/WarnCard.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart';

import 'class/class_WarnMessage.dart';

import 'widgets/StatusWidget.dart';

import 'MyPlacesView.dart';
import 'SettingsView.dart';

import 'services/notification_service.dart';
import 'services/CheckForMyPlacesWarnings.dart';
import 'services/GetData.dart';
import 'services/updateProvider.dart';
import 'services/saveAndLoadSharedPreferences.dart';
import 'services/listHandler.dart';
import 'services/markWarningsAsRead.dart';

// Background services
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    bool response = false;
    print("Native called background task: " + task);
    switch (task) {
      case "call APIs":
        // load warnings in Background and notify if necessary
        response = await checkForWarnings();
        print("Call APIs executed");
        break;
    }
    //simpleTask will be emitted here.
    return Future.value(response);
  });
}

void main() async {
  // some initialisation
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          false // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  loadReadWarningsList(); // load the list with ids of read warnings
  loadFrequencyOfAPICall(); //load in settings defined frequency
  loadSettings(); // load settings / load the saved value of 'notificationGeneral'
  if (notificationGeneral) {
    // setup the background task
    print("Background notification enabled");
    Workmanager().cancelAll(); //cancel old tasks
    Workmanager().registerPeriodicTask("1", "call APIs",
        frequency: Duration(minutes: frequencyOfAPICall.toInt())); //register new task
  } else {
    // the user do not want the background task
    print("Background notification disabled");
  }

  runApp(
    ChangeNotifierProvider(
      // ChangeNotifier to rebuild the widget, if data from outside changed
      create: (context) => Update(),
      child: Consumer<Update>(
          builder: (context, counter, child) => MyApp()), // theme: appThemeData
    ),
  );
}
// global vars
// status = true if API call and parsing was successful
bool mowasStatus = false;
bool mowasParseStatus = false;
bool katwarnStatus = false;
bool katwarnParseStatus = false;
bool biwappStatus = false;
bool biwappParseStatus = false;
bool dwdStatus = false;
bool dwdParseStatus = false;
//count number von warnings
int mowasMessages = 0;
int katwarnMessages = 0;
int biwappMessages = 0;
int dwdMessages = 0;

bool firstStart = true;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foss Warn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScaffoldView(),
    );
  }
}

class ScaffoldView extends StatefulWidget {
  const ScaffoldView({Key? key}) : super(key: key);

  @override
  _ScaffoldViewState createState() => _ScaffoldViewState();
}

class _ScaffoldViewState extends State<ScaffoldView> {
  int _selectedIndex = 0; // selected view
  // the navigation bar
  void _onItemTapped(int index) {
    // change view
    setState(() {
      _selectedIndex = index;
    });
  }
  // list of views for the navigation bar
  static const List<Widget> _pages = <Widget>[
    HomeView(),
    MyPlaces(),
    Settings(),
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadMyPlacesList(); //load MyPlaceList
    listenNotifications(); // listen to notification stream
  }
  void listenNotifications() {
    NotificationService.onNotification.stream.listen((onClickedNotification));
  }

  void onClickedNotification(String? payload) {
    //change view to "MyPlaces"
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Foss Warn"),
          systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
          backgroundColor: Colors.green[700],
          actions: [
            IconButton(
              onPressed: () {
                markAllWarningsAsReadFromMain(context);
                final snackBar = SnackBar(
                  content: const Text(
                    'Alle Warnungen als gelesen markiert',
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.green[100],
                );

                // Find the ScaffoldMessenger in the widget tree
                // and use it to show a SnackBar.
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              icon: Icon(Icons.mark_chat_read),
              tooltip: "Markiere alle Warnungen als gelesen",
            ),
            IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatusWidget();
                    },
                  );
                },
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.add_alert),
              label: 'Alle Meldungen',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.place),
              label: 'Meine Orte',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Einstellungen',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
        body: _pages.elementAt(_selectedIndex));
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
      await Future.delayed(Duration(seconds: 2));
    }

    void loadData() async {
      data = await getData();
      loadNotificationSettingsImportanceList();
      setState(() {
        loading = false;
      });
    }

    if (loading == true) {
      loadData();
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

    return RefreshIndicator(
      onRefresh: reloadData,
      child: SingleChildScrollView(
        child: Column(
          children: warnMessageList
              .map((warnMessage) => WarnCard(warnMessage: warnMessage))
              .toList(),
        ),
      ),
    );
  }
}
