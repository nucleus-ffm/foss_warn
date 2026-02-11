import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../services/self_check_handler.dart';
import '../../services/server.dart';
import 'package:qr/qr.dart';

enum MainMenuItem {
  settings,
  about,
}

class HomeViewTV extends ConsumerStatefulWidget {
  const HomeViewTV({
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
  ConsumerState<HomeViewTV> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeViewTV> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();

    var userPreferences = ref.read(userPreferencesProvider);
    selectedIndex = userPreferences.startScreen;

    NotificationService.onNotification.stream.listen(onClickedNotification);

    startServer(ref);
  }

  void onClickedNotification(String? payload) {
    // Change view to "MyPlaces"
    selectedIndex = 1;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;

    ref.watch(selfCheckProvider);

    /// return the first Ip address that is found
    Future<String?> getIP() async {
      for (var interface in await NetworkInterface.list()) {
        print('== Interface: ${interface.name} ==');
        return interface.addresses.first.address;
        // for (var addr in interface.addresses) {
        //   print(
        //       '${addr.address} ${addr.host} ${addr.isLoopback} ${addr.rawAddress} ${addr.type.name}');
        // }
      }
      return null;
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
        title: const Text("FOSS Warn TV client"),
        actions: [
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

      body: Center(
        child: FutureBuilder<String?>(
          future: getIP(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                final String data = snapshot.data!;
                debugPrint(data);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  QrImageView(
                    data: data,
                    version: QrVersions.auto,
                    eyeStyle: QrEyeStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    size: 200.0,
                  ),
                  const SizedBox(height: 20,),
                  const Text("Scan this QR code with FOSSWarn to connect"),
                  Text("or enter this IP manually: $data"),
                ]);
              } else {
                debugPrint(
                    "Error getting system information: ${snapshot.error}");
                return const Text(
                  "Error. No IP address found",
                  style: TextStyle(color: Colors.red),
                );
              }
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
