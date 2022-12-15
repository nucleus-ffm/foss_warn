// import 'dart:async';
// import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_alarmManager.dart';
import 'package:foss_warn/services/geocodeHandler.dart';
import 'package:foss_warn/services/listHandler.dart';
import 'package:foss_warn/views/aboutView.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';




import 'widgets/SourceStatusWidget.dart';

import 'views/MyPlacesView.dart';
import 'views/SettingsView.dart';
import 'views/AllWarningsView.dart';
import 'views/WelcomeView.dart';

import 'class/class_NotificationService.dart';

import 'services/updateProvider.dart';
import 'services/saveAndLoadSharedPreferences.dart';
import 'services/markWarningsAsRead.dart';
import 'services/sortWarnings.dart';

import 'widgets/dialogs/SortByDialog.dart';
import 'themes/themes.dart';

//final navigatorKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // some initialisation
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  loadReadWarningsList(); // load the list with ids of read warnings
  await loadSettings(); // load settings / load the saved value of 'notificationGeneral'

  if (notificationGeneral) {
    // setup the background task
    print("Background notification enabled");
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
int dataFetchStatusOldAPI = 0; // 0= no info, 1 = successful, 2 = error

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
      theme: greenTheme,
      darkTheme: darkTheme,
      themeMode: selectedTheme,
      navigatorKey: navigatorKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('en', ''),
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
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadMyPlacesList(); //load MyPlaceList
    listenNotifications();
    if (geocodeMap.isEmpty) {
      print("call geocode handler");
      geocodeHandler();
    }
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
          backgroundColor: Theme.of(context).colorScheme.secondary,
          actions: [
            showAllWarnings
                ? IconButton(
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
                : SizedBox(),
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
                  content: Text(
                    AppLocalizations.of(context).main_app_bar_tooltip_mark_all_warnings_as_read,
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.green[100],
                );

                // Find the ScaffoldMessenger in the widget tree
                // and use it to show a SnackBar.
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              icon: Icon(Icons.mark_chat_read),
              tooltip: AppLocalizations.of(context).main_app_bar_tooltip_mark_all_warnings_as_read,
            ),
            PopupMenuButton(
                icon: Icon(Icons.more_vert),
                onSelected: (result) {
                  switch(result) {
                    case 0:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Settings()),
                      );
                      break;
                    case 1:
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutView()),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry>[
                      PopupMenuItem(child: Text( AppLocalizations.of(context).main_dot_menu_settings), value: 0),
                      PopupMenuItem(child: Text(AppLocalizations.of(context).main_dot_menu_about), value: 1)
                    ])
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.add_alert),
              label: AppLocalizations.of(context).main_nav_bar_all_warnings,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.place),
              label: AppLocalizations.of(context).main_nav_bar_my_places,
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
