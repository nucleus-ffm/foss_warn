import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/class/class_unified_push_handler.dart';
import 'package:foss_warn/main.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/save_and_load_shared_preferences.dart';
import 'package:foss_warn/services/update_provider.dart';
import 'package:foss_warn/views/about_view.dart';
import 'package:foss_warn/views/all_warnings_view.dart';
import 'package:foss_warn/views/map_view.dart';
import 'package:foss_warn/views/my_places_view.dart';
import 'package:foss_warn/views/settings_view.dart';
import 'package:foss_warn/widgets/dialogs/sort_by_dialog.dart';
import 'package:unifiedpush/unifiedpush.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int _selectedIndex = userPreferences.startScreen; // selected start view

  // list of views for the navigation bar
  final List<Widget> _pages = <Widget>[
    const AllWarningsView(),
    const MyPlaces(),
    const MapView(),
  ];

  @override
  void initState() {
    super.initState();

    var places = ref.read(myPlacesProvider);

    // init unified push
    UnifiedPush.initialize(
      onNewEndpoint: UnifiedPushHandler
          .onNewEndpoint, // takes (String endpoint, String instance) in args
      onRegistrationFailed:
          UnifiedPushHandler.onRegistrationFailed, // takes (String instance)
      onUnregistered:
          UnifiedPushHandler.onUnregistered, // takes (String instance)
      onMessage: (message, instance) => UnifiedPushHandler.onMessage(
        alertApi: ref.read(alertApiProvider),
        message: message,
        instance: instance,
        myPlaces: places,
      ), // takes (Uint8List message, String instance) in args
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(myPlacesProvider.notifier).places = await loadMyPlacesList();
    });

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
    var localizations = AppLocalizations.of(context)!;
    var scaffoldMessenger = ScaffoldMessenger.of(context);

    var updater = ref.read(updaterProvider);
    var places = ref.watch(myPlacesProvider);

    return Scaffold(
      // set to false to prevent the widget from jumping after closing the keyboard
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("FOSS Warn"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: localizations.main_app_bar_action_sort_tooltip,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => const SortByDialog(),
              );
              updater.updateReadStatusInList();
            },
          ),
          IconButton(
            onPressed: () {
              for (Place p in places) {
                p.markAllWarningsAsRead(ref);
              }

              final snackBar = SnackBar(
                content: Text(
                  localizations.main_app_bar_tooltip_mark_all_warnings_as_read,
                ),
              );

              scaffoldMessenger.showSnackBar(snackBar);
            },
            icon: const Icon(Icons.mark_chat_read),
            tooltip:
                localizations.main_app_bar_tooltip_mark_all_warnings_as_read,
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (result) {
              switch (result) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Settings()),
                  );
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutView()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                value: 0,
                child: Text(localizations.main_dot_menu_settings),
              ),
              PopupMenuItem(
                value: 1,
                child: Text(localizations.main_dot_menu_about),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.warning),
            label: localizations.main_nav_bar_all_warnings,
          ),
          NavigationDestination(
            icon: const Icon(Icons.place),
            label: localizations.main_nav_bar_my_places,
          ),
          const NavigationDestination(
            icon: Icon(Icons.map),
            label: "Map",
          ),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
      ),
      body: _pages.elementAt(_selectedIndex),
    );
  }
}
