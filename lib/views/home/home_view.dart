import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/class/class_unified_push_handler.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/services/demo_alerts.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/warnings.dart';
import 'package:foss_warn/views/warnings_view.dart';
import 'package:foss_warn/views/map_view.dart';
import 'package:foss_warn/views/my_places_view.dart';
import 'package:foss_warn/widgets/dialogs/sort_by_dialog.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';
import 'package:unifiedpush_storage_shared_preferences/storage.dart';

import '../../services/legacy_handler.dart';
import '../../services/self_check_handler.dart';
import '../../services/subscription_handler.dart';

enum MainMenuItem {
  settings,
  about,
}

enum DemoAlertsMenuItem {
  weatherWarning,
  floodWarning,
  bombFoundWarning,
  thunderstormWarning,
  removeWarning,
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userPreferences.showUpdateDialog) {
        showUpdateDialog(context, ref);
      }
    });
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

    Future<void> onPopupDemoAlertPressed(DemoAlertsMenuItem item) async {
      switch (item) {
        case DemoAlertsMenuItem.weatherWarning:
          injectWeatherWarning(ref, context);
          break;
        case DemoAlertsMenuItem.floodWarning:
          injectFloodWarning(ref, context);
          break;
        case DemoAlertsMenuItem.bombFoundWarning:
          injectBombWarning(ref, context);
          break;
        case DemoAlertsMenuItem.thunderstormWarning:
          injectThunderstormWarning(ref, context);
          break;
        case DemoAlertsMenuItem.removeWarning:
          removeDemoAlert(ref);
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

          /*TextButton(
            child: Text("Test alert"),
            //tooltip: "show a test notification",
            onPressed: () {
              //injectWarning(ref, context);

              /*NotificationService.showNotification(
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
              );*/
            },
          ),*/
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.sort,
                size: IconTheme.of(context).size,
              ),
              tooltip: localizations.main_app_bar_action_sort_tooltip,
              onPressed: onOpenSortDialog,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: IconButton(
              onPressed: places.isNotEmpty ? onMarkNotificationAsRead : null,
              icon: Icon(
                Icons.mark_chat_read,
                size: IconTheme.of(context).size,
              ),
              tooltip:
                  localizations.main_app_bar_tooltip_mark_all_warnings_as_read,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: IconButton(
              onPressed: widget.onSettingsPressed,
              icon: Icon(
                Icons.settings,
                size: IconTheme.of(context).size,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: IconButton(
              onPressed: widget.onAboutPressed,
              icon: Icon(
                Icons.info_outline,
                size: IconTheme.of(context).size,
              ),
            ),
          ),

          PopupMenuButton<DemoAlertsMenuItem>(
            icon: Icon(
              Icons.more_vert,
              size: IconTheme.of(context).size,
            ),
            onSelected: onPopupDemoAlertPressed,
            itemBuilder: (context) => <PopupMenuEntry<DemoAlertsMenuItem>>[
              const PopupMenuItem(
                value: DemoAlertsMenuItem.weatherWarning,
                child: Text("Forst Warnung (1/4)"),
              ),
              const PopupMenuItem(
                value: DemoAlertsMenuItem.thunderstormWarning,
                child: Text("Gewitter Warnung (2/4)"),
              ),
              const PopupMenuItem(
                value: DemoAlertsMenuItem.bombFoundWarning,
                child: Text("Bombenfund Warnung (3/4)"),
              ),
              const PopupMenuItem(
                value: DemoAlertsMenuItem.floodWarning,
                child: Text("Hochwasser Warnung (4/4"),
              ),
              const PopupMenuItem(
                value: DemoAlertsMenuItem.removeWarning,
                child: Text("Entferne Demo Warnung"),
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
