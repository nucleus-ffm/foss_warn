import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/class/class_unified_push_handler.dart';
import 'package:foss_warn/main.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/update_provider.dart';
import 'package:foss_warn/services/warnings.dart';
import 'package:foss_warn/views/about_view.dart';
import 'package:foss_warn/views/warnings_view.dart';
import 'package:foss_warn/views/map_view.dart';
import 'package:foss_warn/views/my_places_view.dart';
import 'package:foss_warn/views/settings_view.dart';
import 'package:foss_warn/widgets/dialogs/sort_by_dialog.dart';
import 'package:unifiedpush/unifiedpush.dart';

enum MainMenuItem {
  settings,
  about,
}

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int selectedIndex = userPreferences.startScreen;

  @override
  void initState() {
    super.initState();

    var places = ref.read(myPlacesProvider);

    // init unified push
    UnifiedPush.initialize(
      onNewEndpoint: UnifiedPushHandler.onNewEndpoint,
      onRegistrationFailed: UnifiedPushHandler.onRegistrationFailed,
      onUnregistered: UnifiedPushHandler.onUnregistered,
      onMessage: (message, instance) => UnifiedPushHandler.onMessage(
        alertApi: ref.read(alertApiProvider),
        myPlacesService: ref.read(myPlacesProvider.notifier),
        warningService: ref.read(warningsProvider.notifier),
        message: message,
        instance: instance,
        myPlaces: places,
      ),
    );

    UnifiedPushHandler.setupUnifiedPush(context, ref);

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

    var updater = ref.read(updaterProvider);
    var places = ref.watch(myPlacesProvider);

    var body = switch (selectedIndex) {
      1 => const MyPlacesView(),
      2 => const MapView(),
      _ => const WarningsView(),
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
      updater.updateReadStatusInList();
    }

    void onMarkNotificationAsRead() {
      ref.read(warningsProvider.notifier).markAllWarningsAsRead();

      final snackBar = SnackBar(
        content: Text(
          localizations.main_app_bar_tooltip_mark_all_warnings_as_read,
        ),
      );

      scaffoldMessenger.showSnackBar(snackBar);
    }

    Future<void> onPopupMenuPressed(MainMenuItem item) async {
      // TODO(PureTryOut): replace for go_router
      switch (item) {
        case MainMenuItem.settings:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Settings()),
          );
          break;
        case MainMenuItem.about:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutView()),
          );
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
