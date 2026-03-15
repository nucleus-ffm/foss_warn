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
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';
import 'package:unifiedpush_storage_shared_preferences/storage.dart';

import '../../services/self_check_handler.dart';
import '../../services/subscription_handler.dart';

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
    required this.onNotificationSelfCheckPressed,
    super.key,
  });

  final VoidCallback onAddPlacePressed;
  final void Function(String placeSubscriptionId) onPlacePressed;
  final void Function(String alertId, String subcriptionId) onAlertPressed;
  final VoidCallback onAlertUpdateThreadPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onAboutPressed;
  final VoidCallback onNotificationSelfCheckPressed;

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
    // In a dev environment with multiple hot restarts, this registers multiple callbacks
    UnifiedPush.initialize(
      onNewEndpoint: unifiedPushHandler.onNewEndpoint,
      onRegistrationFailed: unifiedPushHandler.onRegistrationFailed,
      onUnregistered: unifiedPushHandler.onUnregistered,
      linuxOptions: LinuxOptions(
        dbusName: "de.nucleus.foss_warn",
        storage: UnifiedPushStorageSharedPreferences(),
        background: false,
      ),
      onMessage: (message, instance) => unifiedPushHandler.onMessage(
        message: message,
        instance: instance,
        ref: ref,
        alertApi: ref.read(alertApiProvider),
        myPlacesService: ref.read(myPlacesProvider.notifier),
        warningService: ref.read(processedAlertsProvider.notifier),
        context: context,
      ),
    ).then((registered) {
      if (registered) {
        // as we are already registered, we don't have to call setupUnifiedPush
        UnifiedPush.register(
          instance: UserPreferences.unifiedPushInstance,
        );
      } else {
        if (!mounted) {
          return;
        }
        // setup unifiedPush at every startup
        unifiedPushHandler.setupUnifiedPush(context, ref);
      }
    });
    // update all subscriptions
    updateAllSubscriptions(ref);

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
    ref.watch(selfCheckProvider);

    var body = switch (selectedIndex) {
      1 => MyPlacesView(
          onAddPlacePressed: widget.onAddPlacePressed,
          onPlacePressed: widget.onPlacePressed,
          onNotificationSelfCheckPressed: widget.onNotificationSelfCheckPressed,
        ),
      2 => const MapView(),
      _ => WarningsView(
          onAlertPressed: widget.onAlertPressed,
          onAlertUpdateThreadPressed: widget.onAlertUpdateThreadPressed,
          onNotificationSelfCheckPressed: widget.onNotificationSelfCheckPressed,
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
          // @TODO debug only, remove before release
          IconButton(
            icon: Icon(
              Icons.notifications_on_rounded,
              size: IconTheme.of(context).size,
            ),
            tooltip: "show a test notification",
            onPressed: () {
              NotificationService.showNotification(
                // generate from the warning in the List the notification id
                // because the warning identifier is no int, we have to generate a hash code
                id: 5,
                title: "Test Benachrichtigung",
                body: "Das ist eine Test Benachrichtigung",
                payload: "",
                channelId: "de.nucleus.foss_warn.notifications_moderate",
                sender: "FOSSWarn",
                severity: "Schwer",
                instructions: "Bleiben sie Zuhause",
                categories: ["Wetter"],
                channelName: "Moderate",
                userPreferences: ref.read(userPreferencesProvider),
                alertID: "1f45a843-a391-4675-b4a0-91b077be028b",
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.sort,
              size: IconTheme.of(context).size,
            ),
            tooltip: localizations.main_app_bar_action_sort_tooltip,
            onPressed: onOpenSortDialog,
          ),
          IconButton(
            onPressed: places.isNotEmpty ? onMarkNotificationAsRead : null,
            icon: Icon(
              Icons.mark_chat_read,
              size: IconTheme.of(context).size,
            ),
            tooltip:
                localizations.main_app_bar_tooltip_mark_all_warnings_as_read,
          ),
          PopupMenuButton<MainMenuItem>(
            icon: Icon(
              Icons.more_vert,
              size: IconTheme.of(context).size,
            ),
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
            icon: Icon(Icons.warning, size: IconTheme.of(context).size),
            label: localizations.main_nav_bar_all_warnings,
          ),
          NavigationDestination(
            icon: Icon(Icons.place, size: IconTheme.of(context).size),
            label: localizations.main_nav_bar_my_places,
          ),
          NavigationDestination(
            icon: Icon(
              Icons.map,
              size: IconTheme.of(context).size,
            ),
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
