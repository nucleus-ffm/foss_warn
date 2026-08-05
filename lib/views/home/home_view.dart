import 'package:flutter/material.dart';
import 'package:foss_warn/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/class/class_unified_push_handler.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/warnings.dart';
import 'package:foss_warn/views/warnings_view.dart';
import 'package:foss_warn/views/map_view.dart';
import 'package:foss_warn/views/my_places_view.dart';
import 'package:foss_warn/widgets/dialogs/sort_by_dialog.dart';

import '../../services/legacy_handler.dart';
import '../../class/class_alarm_manager.dart';
import '../../enums/alert_service.dart';
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
  late bool startedWithIntroduction;

  /// setup push notifications and alarm manager
  ///
  /// This method won't do anything if it is called
  /// when the user is currently seeing the welcome screen
  Future<void> setup() async {
    var userPreferences = ref.read(userPreferencesProvider);

    // only init after the welcome screen to avoid overwhelming the user at first start
    // check the app state if we UnifiedPush is already registered for avoid doing that multiple times
    if (!userPreferences.showWelcomeScreen) {
      var unifiedPushHandler = ref.read(unifiedPushHandlerProvider);
      // init registers the callbacks and if push is enabled it also setups
      // UP, if not enabled, this has to happen later
      await unifiedPushHandler.initialize(ref, context);

      // update the subscription only if push is enabled
      if (userPreferences.alertService == AlertService.push ||
          userPreferences.alertService == AlertService.pushAndPoll) {
        // update all subscriptions
        updateAllSubscriptions(ref);
      }

      if (userPreferences.alertService == AlertService.poll ||
          userPreferences.alertService == AlertService.pushAndPoll) {
        AlarmManager.registerBackgroundPollingTask();
      }
      if (userPreferences.locationTracking) {
        AlarmManager.registerBackgroundLocationTask();
      }
    }
  }

  @override
  void initState() {
    super.initState();

    var userPreferences = ref.read(userPreferencesProvider);
    selectedIndex = userPreferences.startScreen;

    NotificationService.onNotification.stream.listen(onClickedNotification);
    startedWithIntroduction = userPreferences.showWelcomeScreen;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userPreferences.showUpdateDialog) {
        showUpdateDialog(context, ref);
      }
    });
    setup();
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

    // this checks if the state of the showIntroductionScreen changed since
    // creating this widget and if yes, the introduction is done
    // and we can setup UnifiedPush etc.
    bool startedWithIntroductionNow = ref.watch(
      userPreferencesProvider
          .select((userPreferences) => userPreferences.showWelcomeScreen),
    );
    if (startedWithIntroduction != startedWithIntroductionNow) {
      setup();
    }

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
