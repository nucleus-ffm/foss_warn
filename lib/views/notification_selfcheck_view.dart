import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/extensions/list.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../class/class_bounding_box.dart';
import '../class/class_fpas_place.dart';
import '../class/class_notification_service.dart';
import '../class/class_unified_push_handler.dart';
import '../class/class_user_preferences.dart';
import '../constants.dart';
import '../services/alert_api/fpas.dart';
import '../services/api_handler.dart';
import '../services/list_handler.dart';
import '../services/subscription_handler.dart';
import '../services/url_launcher.dart';

class NotificationSelfCheckView extends ConsumerStatefulWidget {
  const NotificationSelfCheckView({super.key});

  @override
  ConsumerState<NotificationSelfCheckView> createState() =>
      _NotificationSelfCheckState();
}

/// enum to handle the state of the self check tests
enum SelfCheckState {
  passed,
  notPassed,
  actionSuggested,
  unknown,
}

class _NotificationSelfCheckState
    extends ConsumerState<NotificationSelfCheckView> {
  SelfCheckState notificationPermissionState = SelfCheckState.unknown;
  SelfCheckState isServerOkState = SelfCheckState.unknown;
  SelfCheckState endpointState = SelfCheckState.unknown;
  SelfCheckState distributorState = SelfCheckState.unknown;
  SelfCheckState selectedDistributorState = SelfCheckState.unknown;
  SelfCheckState subscriptionState = SelfCheckState.unknown;
  SelfCheckState notificationState = SelfCheckState.unknown;

  List<Map<String, String>>? distributorList;
  String? selectedDistributor;
  String? endpoint;

  /// check the state of the notification permission
  /// returns SelfCheckState.passed if the permission is granted and
  /// SelfCheckState.notPassed if not
  Future<SelfCheckState> checkNotificationPermission() async {
    print("Hallo");
    if (Platform.isAndroid || Platform.isIOS) {
      bool permission = await Permission.notification.status.isGranted;
      return permission ? SelfCheckState.passed : SelfCheckState.notPassed;
    }
    print("check notification permission");
    return SelfCheckState.passed;
  }

  /// request the Notification permission
  Future<void> requestNotificationPermission() async {
    if(Platform.isAndroid || Platform.isIOS) {
      bool permissionRequest = await Permission.notification.request().isGranted;
      notificationPermissionState =
      permissionRequest ? SelfCheckState.passed : SelfCheckState.notPassed;
      setState(() {});
    }
  }

  /// Check the list of available distributor on the system
  /// Stores the list in the distributorList var
  Future<SelfCheckState> checkUnifiedPushDistributor() async {
    var unifiedPushHandler = ref.read(unifiedPushHandlerProvider);
    List<Map<String, String>> list =
        await unifiedPushHandler.getListOfDistributors();
    distributorList = list;
    if (list.isNotEmpty) {
      return SelfCheckState.passed;
    } else {
      return SelfCheckState.notPassed;
    }
  }

  /// Check which distributor is currently selected
  Future<SelfCheckState> checkCurrentDistributor() async {
    var unifiedPushHandler = ref.read(unifiedPushHandlerProvider);
    String? distributor = await unifiedPushHandler.getDistributor();
    if (distributor != null) {
      selectedDistributor = distributor;
      return SelfCheckState.passed;
    } else {
      return SelfCheckState.notPassed;
    }
  }

  /// uses the distributorList and returns a formatted String that can be passed
  /// as subtitle to the list tile
  String formatUnifiedPushDistributorList() {
    if (distributorList == null) {
      return "no distributor found";
    }
    StringBuffer result = StringBuffer();
    for (Map<String, String> distributor in distributorList!) {
      result.writeAll(
        [distributor["name"], " (", distributor["distributor"], ")", "\n"],
      );
    }
    return result.toString();
  }

  /// check the selected endpoint for unifiedpush and
  /// store the endpoint the the endpoint var
  Future<SelfCheckState> checkSelectedEndpoint() async {
    var userPreferences = ref.read(userPreferencesProvider);
    endpoint = userPreferences.unifiedPushEndpoint;
    if (endpoint != "") {
      return SelfCheckState.passed;
    } else {
      return SelfCheckState.notPassed;
    }
  }

  /// check if user server is in the list of servers with known issues or in the list
  /// of server that are not working at all
  SelfCheckState checkIfServerIsOk() {
    if (endpoint != null && endpoint != "") {
      // for server that are known to make some trouble
      for (String serverName in serversWithIssues) {
        if (endpoint!.contains(serverName)) {
          return SelfCheckState.actionSuggested;
        }
      }
      // server that are not working at all
      for (String serverName in serverThatAreNotWorking) {
        if (endpoint!.contains(serverName)) {
          return SelfCheckState.notPassed;
        }
      }
      return SelfCheckState.passed;
    }
    return SelfCheckState.unknown;
  }

  /// the final test if everything is working
  /// subscribes to the test alerts, waits until the notifications arrives and
  /// removes the subscription afterwards again
  /// this test requires, that all other tests are passed
  Future<({SelfCheckState subscriptionState, SelfCheckState notificationState})>
      testSubscriptionAndNotification() async {
    if (notificationPermissionState != SelfCheckState.passed ||
        // check if serverOk state is not either passed or action suggested
        !(isServerOkState == SelfCheckState.passed ||
            isServerOkState == SelfCheckState.actionSuggested) ||
        endpointState != SelfCheckState.passed ||
        distributorState != SelfCheckState.passed ||
        selectedDistributorState != SelfCheckState.passed) {
      // one of the other checks failed, we will not try to subscribe
      return (
        subscriptionState: SelfCheckState.notPassed,
        notificationState: SelfCheckState.unknown
      );
    }

    String testAlertPlaceName = "Test subscription";
    var api = ref.read(alertApiProvider);
    String confirmationId = "";
    try {
      confirmationId = await subscribeForArea(
        // FPAS publishes its test alerts for Point Nemo as
        // this point has the maximal distance to the next
        // coast in the world.
        boundingBox: BoundingBox(
          minLatLng: const LatLng(-48.8767, -124.3933),
          maxLatLng: const LatLng(-47.8767, -122.3933),
        ),
        selectedPlaceName: testAlertPlaceName,
        context: context,
        ref: ref,
      );
    } on RegisterAreaError {
      // do not set the switch to true
      return (
        subscriptionState: SelfCheckState.notPassed,
        notificationState: SelfCheckState.unknown
      );
    } on SocketException {
      // do not set the switch to true
      return (
        subscriptionState: SelfCheckState.notPassed,
        notificationState: SelfCheckState.unknown
      );
    } on UnifiedPushRegistrationTimeoutError {
      // do not set the switch to true
      return (
        subscriptionState: SelfCheckState.notPassed,
        notificationState: SelfCheckState.unknown
      );
    }

    bool successfullyNotification =
    await NotificationService.isNotificationActive(confirmationId.hashCode);

    // @TODO (Nucleus): An useful addition would be to check if the notification arrived and let the user click on the notification

    // remove subscription
    var places = ref.read(myPlacesProvider.notifier);
    Place? place = places.places.firstWhereOrNull(
      (p) => p.name == testAlertPlaceName,
    );
    if (place != null) {
      try {
        await api.unregisterArea(
          subscriptionId: place.subscriptionId,
        );
        places.remove(place);
        debugPrint("[NotificationSelfCheck] Place successfully removed");
      } on UnregisterAreaError {
        debugPrint("[NotificationSelfCheck] UnregisterAreaError");
        return (
          subscriptionState: SelfCheckState.notPassed,
          notificationState: SelfCheckState.unknown
        );
      }
    }

    return (
      subscriptionState: SelfCheckState.passed,
      notificationState: successfullyNotification
          ? SelfCheckState.passed
          : SelfCheckState.notPassed
    );
  }

  // run several self checks to detect problems
  Future<void> runSelfCheck() async {
    notificationPermissionState = await checkNotificationPermission();
    if (!mounted) return;
    setState(() {});
    distributorState = await checkUnifiedPushDistributor();
    if (!mounted) return;
    setState(() {});
    selectedDistributorState = await checkCurrentDistributor();
    if (!mounted) return;
    setState(() {});
    distributorState = await checkUnifiedPushDistributor();
    if (!mounted) return;
    setState(() {});
    endpointState = await checkSelectedEndpoint();
    if (!mounted) return;
    setState(() {});
    isServerOkState = checkIfServerIsOk();
    if (!mounted) return;
    setState(() {});
    distributorState = await checkUnifiedPushDistributor();
    if (!mounted) return;
    setState(() {});
    selectedDistributorState = await checkCurrentDistributor();
    if (!mounted) return;
    setState(() {});
    var subscriptionTestResult = await testSubscriptionAndNotification();
    subscriptionState = subscriptionTestResult.subscriptionState;
    if(Platform.isLinux) {
      // there is no way to get the active notifications on Linux
      notificationState = SelfCheckState.unknown;
    } else {
      notificationState = subscriptionTestResult.notificationState;
    }
   
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      runSelfCheck();
    });
  }

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;

    /// build one list tile for one check
    ListTile buildCheckListTile({
      required String title,
      required String subtitlePassed,
      required String subtitleNotPassed,
      required String subtitleUnknown,
      required subtitleActionSuggested,
      required SelfCheckState state,
      String? additionalContext,
      Function()? onTap,
    }) {
      String subtitle = "";
      IconData icon;
      Color color;
      Color textColor;

      switch (state) {
        case SelfCheckState.unknown:
          subtitle = subtitleUnknown;
          icon = Icons.manage_search;
          color = Colors.transparent;
          textColor = Theme.of(context).colorScheme.onSurface;
        case SelfCheckState.passed:
          subtitle = subtitlePassed;
          icon = Icons.check;
          color = Theme.of(context).colorScheme.primary;
          textColor = Theme.of(context).colorScheme.onPrimary;
        case SelfCheckState.notPassed:
          subtitle = subtitleNotPassed;
          icon = Icons.error;
          color = Theme.of(context).colorScheme.error;
          textColor = Theme.of(context).colorScheme.onError;
        case SelfCheckState.actionSuggested:
          subtitle = subtitleActionSuggested;
          icon = Icons.construction;
          color = Theme.of(context).colorScheme.surfaceContainerHighest;
          textColor = Theme.of(context).colorScheme.onSurface;
      }

      return ListTile(
        //@TODO: (Nucleus) move style to theme
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle:
            Text(subtitle, style: TextStyle(fontSize: 14, color: textColor)),
        trailing: Icon(icon, color: textColor),
        onTap: onTap != null ? () => onTap() : null,
        tileColor: color,
        textColor: textColor,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.notification_self_check_title),
        actions: [
          IconButton(
            onPressed: () {
              launchUrlInBrowser(
                "https://github.com/nucleus-ffm/foss_warn/wiki/Notification-self-check",
              );
            },
            tooltip: localizations.help_button_tooltip,
            icon: const Icon(Icons.help),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(localizations.notification_self_check_description),
            ),
            buildCheckListTile(
              title: localizations
                  .notification_self_check_notification_permission_title,
              state: notificationPermissionState,
              subtitlePassed: localizations
                  .notification_self_check_notification_permission_subtitle_passed,
              subtitleNotPassed: localizations
                  .notification_self_check_notification_permission_subtitle_not_passed,
              subtitleUnknown: localizations
                  .notification_self_check_notification_permission_unknown,
              subtitleActionSuggested: "",
              onTap: requestNotificationPermission,
            ),
            buildCheckListTile(
              title: localizations
                  .notification_self_check_installed_distributors_title,
              state: distributorState,
              subtitlePassed: localizations
                  .notification_self_check_installed_distributors_subtitle_passed(
                formatUnifiedPushDistributorList(),
              ),
              subtitleNotPassed: localizations
                  .notification_self_check_installed_distributors_subtitle_not_passed,
              subtitleUnknown: localizations
                  .notification_self_check_installed_distributors_subtitle_unknown,
              subtitleActionSuggested: "",
            ),
            buildCheckListTile(
              title: localizations
                  .notification_self_check_selected_distributor_title,
              subtitlePassed: localizations
                  .notification_self_check_selected_distributor_subtitle_passed(
                selectedDistributor ?? "none",
              ),
              subtitleNotPassed: localizations
                  .notification_self_check_selected_distributor_subtitle_not_passed,
              subtitleUnknown: localizations
                  .notification_self_check_selected_distributor_subtitle_unknown,
              subtitleActionSuggested: "",
              state: selectedDistributorState,
            ),
            buildCheckListTile(
              title:
                  localizations.notification_self_check_current_endpoint_title,
              state: endpointState,
              subtitlePassed: localizations
                  .notification_self_check_current_endpoint_subtitle_passed(
                endpoint ?? "none",
              ),
              subtitleNotPassed: localizations
                  .notification_self_check_current_endpoint_subtitle_not_passed,
              subtitleUnknown: localizations
                  .notification_self_check_current_endpoint_subtitle_unknown,
              subtitleActionSuggested: "",
            ),
            buildCheckListTile(
              title: localizations.notification_self_check_server_check_title,
              state: isServerOkState,
              subtitlePassed: localizations
                  .notification_self_check_server_check_subtitle_passed,
              subtitleNotPassed: localizations
                  .notification_self_check_server_check_subtitle_not_passed,
              subtitleUnknown: localizations
                  .notification_self_check_server_check_subtitle_unknown,
              subtitleActionSuggested: localizations
                  .notification_self_check_server_check_subtitle_action_suggested,
            ),
            buildCheckListTile(
              title:
                  localizations.notification_self_check_test_subscription_title,
              state: subscriptionState,
              subtitlePassed: localizations
                  .notification_self_check_test_subscription_subtitle_passed,
              subtitleNotPassed: localizations
                  .notification_self_check_test_subscription_subtitle_not_passed,
              subtitleUnknown: localizations
                  .notification_self_check_test_subscription_subtitle_unknown,
              subtitleActionSuggested: "",
            ),
            buildCheckListTile(
              title: localizations
                  .notification_self_check_notification_check_title,
              state: notificationState,
              subtitlePassed: localizations
                  .notification_self_check_notification_check_subtitle_passed,
              subtitleNotPassed: localizations
                  .notification_self_check_notification_check_subtitle_not_passed,
              subtitleUnknown: localizations
                  .notification_self_check_notification_check_subtitle_unknown,
              subtitleActionSuggested: "",
            ),
          ],
        ),
      ),
    );
  }
}
