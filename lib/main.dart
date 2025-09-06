import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_unified_push_handler.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/services/legacy_handler.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/views/about_view.dart';
import 'package:foss_warn/views/map_view.dart';
import 'package:foss_warn/views/introduction/introduction_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unifiedpush/unifiedpush.dart';

import 'class/class_app_state.dart';
import 'views/my_places_view.dart';
import 'views/settings_view.dart';
import 'views/all_warnings_view.dart';

import 'class/class_notification_service.dart';

import 'services/update_provider.dart';
import 'services/save_and_load_shared_preferences.dart';

import 'widgets/dialogs/sort_by_dialog.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final AppState appState = AppState();
final UserPreferences userPreferences = UserPreferences();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await legacyHandler();
  await userPreferences.init();
  if (!userPreferences.showWelcomeScreen) {
    // do not ask for notification permission before the user finished the
    // welcome dialog
    await NotificationService().init();
  }

  runApp(FOSSWarn());
}

class FOSSWarn extends StatelessWidget {
  const FOSSWarn({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'FOSS Warn',
        theme: userPreferences.selectedLightTheme,
        darkTheme: userPreferences.selectedDarkTheme,
        themeMode: userPreferences.selectedThemeMode,
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home:
            userPreferences.showWelcomeScreen ? IntroductionView() : HomeView(),
      ),
    );
  }
}

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
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
    UnifiedPush.initialize(
      onNewEndpoint: UnifiedPushHandler
          .onNewEndpoint, // takes (String endpoint, String instance) in args
      onRegistrationFailed:
          UnifiedPushHandler.onRegistrationFailed, // takes (String instance)
      onUnregistered:
          UnifiedPushHandler.onUnregistered, // takes (String instance)
      onMessage: UnifiedPushHandler
          .onMessage, // takes (Uint8List message, String instance) in args
    );

    loadMyPlacesList();
    listenNotifications();
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
    var updater = ref.read(updaterProvider);

    return Scaffold(
        // set to false to prevent the widget from jumping after closing the keyboard
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("FOSS Warn"),
          actions: [
            IconButton(
              icon: Icon(Icons.sort),
              tooltip: AppLocalizations.of(context)!
                  .main_app_bar_action_sort_tooltip,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => SortByDialog(),
                );
                updater.updateReadStatusInList();
              },
            ),
            IconButton(
              onPressed: () {
                for (Place p in myPlaceList) {
                  p.markAllWarningsAsRead(ref);
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
                          value: 0,
                          child: Text(AppLocalizations.of(context)!
                              .main_dot_menu_settings)),
                      PopupMenuItem(
                          value: 1,
                          child: Text(AppLocalizations.of(context)!
                              .main_dot_menu_about))
                    ])
          ],
        ),
        bottomNavigationBar: NavigationBar(
          destinations: <NavigationDestination>[
            NavigationDestination(
                icon: Icon(Icons.warning),
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
