// import 'dart:async';
// import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_alarmManager.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
//import 'package:connectivity_plus/connectivity_plus.dart';

import 'widgets/SourceStatusWidget.dart';

import 'views/MyPlacesView.dart';
import 'views/SettingsView.dart';
import 'views/AllWarningsView.dart';
import 'views/WelcomeView.dart';

import 'class/class_NotificationService.dart';
import 'class/class_BackgroundTask.dart';
import 'class/class_ForegroundService.dart';

import 'services/updateProvider.dart';
import 'services/saveAndLoadSharedPreferences.dart';
import 'services/markWarningsAsRead.dart';
import 'services/sortWarnings.dart';

import 'widgets/dialogs/SortByDialog.dart';

//final navigatorKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/*
// The callback function should always be a top-level function.
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

class FirstTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // You can use the getData function to get the data you saved.
    final customData = await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $customData');
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // Send data to the main isolate.
    sendPort?.send(timestamp);
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    print('onButtonPressed >> $id');
  }
} */

void main() async {
  // some initialisation
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  loadReadWarningsList(); // load the list with ids of read warnings
  await loadSettings(); // load settings / load the saved value of 'notificationGeneral'

  if (notificationGeneral) {
    // ForegroundService stuff
    ForegroundService().initForegroundService();

    // setup the background task
    print("Background notification enabled");
    // workmanager stuff
    // BackgroundTaskManager().initialize();
    BackgroundTaskManager().cancelBackgroundTask();
    // BackgroundTaskManager().registerBackgroundTaskWithDelay();

    // AlarmManager().cancelBackgroundTask(); // just for debug
    AlarmManager().initialize();
    AlarmManager().registerBackgroundTask();
  } else {
    // the user do not want the background task
    print("Background notification disabled");
  }

  runApp(
    ChangeNotifierProvider(
      // ChangeNotifier to rebuild the widget, if data from outside changed
      create: (context) => Update(),

      child: Consumer<Update>(builder: (context, counter, child) => MyApp()),
      // theme: appThemeData
    ),
  );
}

// global varsStatusWidget
// status = true if API call and parsing was successful
bool mowasStatus = false;
bool mowasParseStatus = false;
bool katwarnStatus = false;
bool katwarnParseStatus = false;
bool biwappStatus = false;
bool biwappParseStatus = false;
bool dwdStatus = false;
bool dwdParseStatus = false;
bool lhpStatus = false;
bool lhpParseStatus = false;

// ETags to check if something change serverside to saved data
String mowasEtag = "";
String biwappEtag = "";
String katwarnEtag = "";
String dwdEtag = "";
String lhpEtag = "";

//count number von warnings
int mowasMessages = 0;
int katwarnMessages = 0;
int biwappMessages = 0;
int dwdMessages = 0;
int lhpMessages = 0;

bool firstStart = true;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FOSS Warn',
      theme: useDarkMode
          ? ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSwatch(
                accentColor: Colors.green[700],
                brightness: Brightness.dark,
              ),
              textTheme: const TextTheme(
                  headline1: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  headline2: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  //headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
                  bodyText1: TextStyle(fontSize: 14.0, color: Colors.grey),
                  headline3: TextStyle(fontSize: 14.0, color: Colors.white)),
            )
          : ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSwatch(
                accentColor: Colors.green[700],
                brightness: Brightness.light,
              ),
              textTheme: const TextTheme(
                headline1: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                headline2: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                //headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
                bodyText1: TextStyle(fontSize: 14.0, color: Colors.grey),
                headline3: TextStyle(fontSize: 14.0, color: Colors.white),
              ),
            ),
      //theme: ThemeData.dark(),
      navigatorKey: navigatorKey,
      home: showWelcomeScreen ? WelcomeView() : ScaffoldView(),
    );
  }
}

class ScaffoldView extends StatefulWidget {
  const ScaffoldView({Key? key}) : super(key: key);

  @override
  _ScaffoldViewState createState() => _ScaffoldViewState();
}

class _ScaffoldViewState extends State<ScaffoldView> {
  //late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  int _selectedIndex = startScreen; // selected start view
  // the navigation bar
  void _onItemTapped(int index) {
    // change view
    setState(() {
      _selectedIndex = index;
    });
  }

  // list of views for the navigation bar
  static const List<Widget> _pages = <Widget>[
    AllWarningsView(),
    MyPlaces(),
    Settings(),
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadMyPlacesList(); //load MyPlaceList
    listenNotifications();
    // listen to notification stream

    /*_connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Got a new connectivity status!
      print("Connection changed");
    });*/
  }

  // cancel networt connection subscription
  /*@override
  dispose() {
    super.dispose();

    //_connectivitySubscription.cancel();
  }*/

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
          title: Text("FOSS Warn"),
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          actions: [
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

            ),
            IconButton(
              icon: Icon(Icons.sort),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SortByDialog();
                  },
                );
                sortWarnings();
                final updater = Provider.of<Update>(context, listen: false);
                updater.updateReadStatusInList();
              },
            ),
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
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
        body: _pages.elementAt(_selectedIndex));
  }
}
