import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';


import 'widgets/SourceStatusWidget.dart';

import 'views/MyPlacesView.dart';
import 'views/SettingsView.dart';
import 'views/AllWarningsView.dart';
import 'views/WelcomeView.dart';

import 'class/class_NotificationService.dart';
import 'class/class_BackgroundTask.dart';

import 'services/updateProvider.dart';
import 'services/saveAndLoadSharedPreferences.dart';
import 'services/markWarningsAsRead.dart';
import 'services/sortWarnings.dart';

import 'widgets/dialogs/SortByDialog.dart';

//final navigatorKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // some initialisation
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  // workmanager stuff
  BackgroundTaskManager().initialize();
  loadReadWarningsList(); // load the list with ids of read warnings
  await loadSettings(); // load settings / load the saved value of 'notificationGeneral'

  if (notificationGeneral) {
    // setup the background task
    print("Background notification enabled");
    BackgroundTaskManager().cancelBackgroundTask();
    BackgroundTaskManager().registerBackgroundTask();

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
      title: 'FOSS Warn',
      theme: useDarkMode? ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        textTheme: const TextTheme(
            headline1: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            headline2: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            //headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyText1: TextStyle(fontSize: 14.0, color: Colors.grey),
          headline3: TextStyle(fontSize: 14.0, color: Colors.white)
        ),
      ) :  ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        textTheme: const TextTheme(
            headline1: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            headline2: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
          title: Text("FOSS Warn"),
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
          backgroundColor: Colors.green[700],
          actions: [
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
