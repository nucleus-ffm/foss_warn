import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/class/class_unified_push_handler.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/warnings.dart';
import 'package:foss_warn/views/warnings_view.dart';
import 'package:foss_warn/views/map_view.dart';
import 'package:foss_warn/views/my_places_view.dart';
import 'package:foss_warn/widgets/dialogs/sort_by_dialog.dart';
import 'package:unifiedpush/unifiedpush.dart';

enum MainMenuItem {
  settings,
  about,
}

class HomeView extends ConsumerStatefulWidget {
  const HomeView({
    required this.onAddPlacePressed,
    required this.onPlacePressed,
    required this.onAlertPressed,
    required this.onAlertUpdateThreadPressed,
    required this.onSettingsPressed,
    required this.onAboutPressed,
    super.key,
  });

  final VoidCallback onAddPlacePressed;
  final void Function(String placeSubscriptionId) onPlacePressed;
  final void Function(String alertId) onAlertPressed;
  final VoidCallback onAlertUpdateThreadPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onAboutPressed;

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();

    var userPreferences = ref.read(userPreferencesProvider);
    selectedIndex = userPreferences.startScreen;

    var unifiedPushHandler = ref.read(unifiedPushHandlerProvider);

    // init unified push
    UnifiedPush.initialize(
      onNewEndpoint: unifiedPushHandler.onNewEndpoint,
      onRegistrationFailed: unifiedPushHandler.onRegistrationFailed,
      onUnregistered: unifiedPushHandler.onUnregistered,
      onMessage: (message, instance) => unifiedPushHandler.onMessage(
        message: message,
        instance: instance,
        ref: ref,
        alertApi: ref.read(alertApiProvider),
        myPlacesService: ref.read(myPlacesProvider.notifier),
        warningService: ref.read(processedAlertsProvider.notifier),
        context: context,
      ),
      linuxDBusName: "de.nucleus.foss_warn",
    ).then((registered) {
      UnifiedPush.register(
        instance: UserPreferences.unifiedPushInstance,
      );
    });
    // setup unifiedpush at every startup
    unifiedPushHandler.setupUnifiedPush(context, ref);

    NotificationService.onNotification.stream.listen(onClickedNotification);
  }

  void onClickedNotification(String? payload) {
    // Change view to "MyPlaces"
    selectedIndex = 1;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;
    var scaffoldMessenger = ScaffoldMessenger.of(context);

    var places = ref.watch(myPlacesProvider);

    var body = switch (selectedIndex) {
      1 => MyPlacesView(
          onAddPlacePressed: widget.onAddPlacePressed,
          onPlacePressed: widget.onPlacePressed,
        ),
      2 => const MapView(),
      _ => WarningsView(
          onAlertPressed: widget.onAlertPressed,
          onAlertUpdateThreadPressed: widget.onAlertUpdateThreadPressed,
        ),
    };

    void onDestinationSelected(int index) {
      setState(() {
        selectedIndex = index;
      });
    }

    Future<void> onOpenSortDialog() async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => const SortByDialog(),
      );
    }

    void onMarkNotificationAsRead() {
      markAllWarningsAsRead(ref);

      final snackBar = SnackBar(
        content: Text(
          localizations.main_app_bar_tooltip_mark_all_warnings_as_read,
        ),
      );

      scaffoldMessenger.showSnackBar(snackBar);
    }

    Future<void> onPopupMenuPressed(MainMenuItem item) async {
      switch (item) {
        case MainMenuItem.settings:
          widget.onSettingsPressed();
          break;
        case MainMenuItem.about:
          widget.onAboutPressed();
          break;
      }
    }

    return Scaffold(
      // set to false to prevent the widget from jumping after closing the keyboard
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("FOSS Warn"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: localizations.main_app_bar_action_sort_tooltip,
            onPressed: onOpenSortDialog,
          ),
          IconButton(
            onPressed: places.isNotEmpty ? onMarkNotificationAsRead : null,
            icon: const Icon(Icons.mark_chat_read),
            tooltip:
                localizations.main_app_bar_tooltip_mark_all_warnings_as_read,
          ),
          PopupMenuButton<MainMenuItem>(
            icon: const Icon(Icons.more_vert),
            onSelected: onPopupMenuPressed,
            itemBuilder: (context) => <PopupMenuEntry<MainMenuItem>>[
              PopupMenuItem(
                value: MainMenuItem.settings,
                child: Text(localizations.main_dot_menu_settings),
              ),
              PopupMenuItem(
                value: MainMenuItem.about,
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
          NavigationDestination(
            icon: const Icon(Icons.map),
            label: localizations.main_nav_bar_map,
          ),
        ],
        onDestinationSelected: onDestinationSelected,
        selectedIndex: selectedIndex,
      ),
      body: body,
    );
  }
}
