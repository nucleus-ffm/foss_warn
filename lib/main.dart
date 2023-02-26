import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_alarmManager.dart';
import 'package:foss_warn/services/geocodeHandler.dart';
import 'package:foss_warn/services/listHandler.dart';
import 'package:foss_warn/views/aboutView.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'class/abstract_Place.dart';
import 'enums/DataFetchStatus.dart';
import 'views/MyPlacesView.dart';
import 'views/SettingsView.dart';
import 'views/AllWarningsView.dart';
import 'views/WelcomeView.dart';

import 'class/class_NotificationService.dart';

import 'services/updateProvider.dart';
import 'services/saveAndLoadSharedPreferences.dart';
import 'services/sortWarnings.dart';

import 'widgets/SourceStatusWidget.dart';
import 'widgets/dialogs/SortByDialog.dart';
import 'themes/themes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  // TODO: run Legacy handler, use improved shared preferences types and names

  await loadSettings();

  if (notificationGeneral) {
    print("Background notification enabled");
    // AlarmManager().cancelBackgroundTask(); // just for debug
    AlarmManager().initialize();
    AlarmManager().registerBackgroundTask();
  } else {
    print("Background notification disabled due to user setting");
  }

  runApp(
    // rebuild widget on external data changes
    ChangeNotifierProvider(
      create: (context) => Update(),
      child: Consumer<Update>(builder: (context, counter, child) => FOSSWarn()),
    ),
  );
}

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
DataFetchStatus dataFetchStatusOldAPI = DataFetchStatus.no_info;

// ETags to check for changes in server data since data was fetched
String mowasETag = "";
String biwappETag = "";
String katwarnETag = "";
String dwdETag = "";
String lhpETag = "";

int mowasWarningsCount = 0;
int katwarnWarningsCount = 0;
int biwappWarningsCount = 0;
int dwdWarningsCount = 0;
int lhpWarningsCount = 0;

bool isFirstStart = true;

class FOSSWarn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FOSS Warn',
      theme: greenTheme,
      darkTheme: darkTheme,
      themeMode: selectedTheme,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: showWelcomeScreen ? WelcomeView() : HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = startScreen; // selected start view
  // list of views for the navigation bar
  final List<Widget> _pages = <Widget>[
    AllWarningsView(),
    MyPlaces(),
  ];

  // the navigation bar
  void _onItemTapped(int index) {
    // change view
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    loadMyPlacesList();
    listenNotifications();
    if (geocodeMap.isEmpty) {
      print("call geocode handler");
      geocodeHandler();
    }
  }

  void listenNotifications() {
    NotificationService.onNotification.stream.listen(onClickedNotification);
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
                for(Place p in myPlaceList) {
                  p.markAllWarningsAsRead(context);
                }
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
