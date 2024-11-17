import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_alarmManager.dart';
//import 'package:foss_warn/class/class_UnifiedPushHandler.dart';
import 'package:foss_warn/class/class_userPreferences.dart';
import 'package:foss_warn/services/geocodeHandler.dart';
import 'package:foss_warn/services/legacyHandler.dart';
import 'package:foss_warn/services/listHandler.dart';
import 'package:foss_warn/views/AboutView.dart';
import 'package:foss_warn/views/mapView.dart';
// import 'package:foss_warn/widgets/VectorMapWidget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unifiedpush/unifiedpush.dart';

import 'class/abstract_Place.dart';
import 'class/class_appState.dart';
import 'views/MyPlacesView.dart';
import 'views/SettingsView.dart';
import 'views/AllWarningsView.dart';
import 'views/WelcomeView.dart';

import 'class/class_NotificationService.dart';

import 'services/updateProvider.dart';
import 'services/saveAndLoadSharedPreferences.dart';

import 'widgets/dialogs/SortByDialog.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final AppState appState = AppState();
final UserPreferences userPreferences = UserPreferences();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await legacyHandler();
  await NotificationService().init();
  await loadSettings();

  if (userPreferences.shouldNotifyGeneral) {
    AlarmManager.callback();
    AlarmManager().initialize();
    AlarmManager().registerBackgroundTask();
    print("Background notification enabled");
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

class FOSSWarn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FOSS Warn',
      theme: userPreferences.selectedLightTheme,
      darkTheme: userPreferences.selectedDarkTheme,
      themeMode: userPreferences.selectedThemeMode,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: userPreferences.showWelcomeScreen ? WelcomeView() : HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = userPreferences.startScreen; // selected start view

  // list of views for the navigation bar
  final List<Widget> _pages = <Widget>[
    AllWarningsView(),
    MyPlaces(),
    MapView()
  ];

  @override
  void initState() {
    super.initState();

    // init unified push
    /*UnifiedPush.initialize(
      onNewEndpoint: UnifiedPushHandler
          .onNewEndpoint, // takes (String endpoint, String instance) in args
      onRegistrationFailed:
          UnifiedPushHandler.onRegistrationFailed, // takes (String instance)
      onUnregistered:
          UnifiedPushHandler.onUnregistered, // takes (String instance)
      onMessage: UnifiedPushHandler
          .onMessage, // takes (Uint8List message, String instance) in args
    ); */

    loadMyPlacesList();
    listenNotifications();
    if (geocodeMap.isEmpty) {
      print("call geocode handler");
      geocodeHandler();
    }
    //display information if the app had to be resetted
    showMigrationDialog(context);
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
        // set to false to prevent the widget from jumping after closing the keyboard
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("FOSS Warn"),
          actions: [
            IconButton(
              icon: Icon(Icons.sort),
              tooltip: AppLocalizations.of(context)!.main_app_bar_action_sort_tooltip,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SortByDialog();
                  },
                );
                final updater = Provider.of<Update>(context, listen: false);
                updater.updateReadStatusInList();
              },
            ),
            IconButton(
              onPressed: () {
                for (Place p in myPlaceList) {
                  p.markAllWarningsAsRead(context);
                }
                final snackBar = SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!
                        .main_app_bar_tooltip_mark_all_warnings_as_read,
                  ),
                );

                // Find the ScaffoldMessenger in the widget tree
                // and use it to show a SnackBar.
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              icon: Icon(Icons.mark_chat_read),
              tooltip: AppLocalizations.of(context)!
                  .main_app_bar_tooltip_mark_all_warnings_as_read,
            ),
            PopupMenuButton(
                icon: Icon(Icons.more_vert),
                onSelected: (result) {
                  switch (result) {
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
                      PopupMenuItem(
                          child: Text(AppLocalizations.of(context)!
                              .main_dot_menu_settings),
                          value: 0),
                      PopupMenuItem(
                          child: Text(AppLocalizations.of(context)!
                              .main_dot_menu_about),
                          value: 1)
                    ])
          ],
        ),
        bottomNavigationBar: NavigationBar(
          destinations: <NavigationDestination>[
            NavigationDestination(
                icon: Icon(Icons.add_alert),
                label: AppLocalizations.of(context)!.main_nav_bar_all_warnings),
            NavigationDestination(
                icon: Icon(Icons.place),
                label: AppLocalizations.of(context)!.main_nav_bar_my_places),
            NavigationDestination(icon: Icon(Icons.map), label: "Map")
          ],
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedIndex: _selectedIndex,
        ),
        body: _pages.elementAt(_selectedIndex));
  }
}
