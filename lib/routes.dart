import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/views/about_view.dart';
import 'package:foss_warn/views/add_my_place_with_map_view.dart';
import 'package:foss_warn/views/alert_update_thread_view.dart';
import 'package:foss_warn/views/dev_settings_view.dart';
import 'package:foss_warn/views/home/home_view.dart';
import 'package:foss_warn/views/introduction/introduction_view.dart';
import 'package:foss_warn/views/log_file_viewer.dart';
import 'package:foss_warn/views/my_place_detail_view.dart';
import 'package:foss_warn/views/notification_selfcheck_view.dart';
import 'package:foss_warn/views/notification_settings_view.dart';
import 'package:foss_warn/views/settings_view.dart';
import 'package:foss_warn/views/warning_detail_view.dart';
import 'package:go_router/go_router.dart';

final routesProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      debugPrint("Navigating to ${state.uri.path}");

      var showWelcomeScreen = ref.read(
        userPreferencesProvider
            .select((preferences) => preferences.showWelcomeScreen),
      );

      if (showWelcomeScreen) {
        return "/introduction";
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeView(
          onAddPlacePressed: () => context.go('/places/add'),
          onPlacePressed: (placeSubscriptionId) =>
              context.go('/places/$placeSubscriptionId'),
          onAlertPressed: (String alertId, String subscriptionId) =>
              context.go('/alerts/$alertId/$subscriptionId'),
          onAlertUpdateThreadPressed: () => context.go('/alerts/update'),
          onSettingsPressed: () => context.go('/settings'),
          onAboutPressed: () => context.go('/about'),
          onNotificationSelfCheckPressed: () =>
              context.go("/settings/notification-self-check"),
        ),
        routes: [
          GoRoute(
            path: '/introduction',
            builder: (context, state) => IntroductionView(
              onFinished: () => context.go('/'),
            ),
          ),
          GoRoute(
            path: '/about',
            builder: (context, state) => AboutView(
              onShowLicensePressed: () => context.go('/about/license'),
            ),
            routes: [
              GoRoute(
                path: '/license',
                builder: (context, state) => const LicensePage(),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => Settings(
              onNotificationSettingsPressed: () =>
                  context.go('/settings/notifications'),
              onIntroductionPressed: () => context.go('/introduction'),
              onDevSettingsPressed: () => context.go('/settings/dev-settings'),
              onNotificationSelfCheckPressed: () =>
                  context.go('/settings/notification-self-check'),
            ),
            routes: [
              GoRoute(
                path: 'notification-self-check',
                builder: (context, state) => const NotificationSelfCheckView(),
              ),
              GoRoute(
                path: 'notifications',
                builder: (context, state) => const NotificationSettingsView(),
              ),
              GoRoute(
                path: 'dev-settings',
                builder: (context, state) => DevSettings(
                  onShowLogFilePressed: () =>
                      context.go('/settings/dev-settings/log-file-viewer'),
                ),
                routes: [
                  GoRoute(
                    path: '/log-file-viewer',
                    builder: (context, state) => const LogFileViewer(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/places',
            redirect: (context, state) => null,
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => AddMyPlaceWithMapView(
                  onPlaceAdded: () => context.go('/'),
                ),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  String placeSubscriptionId = state.pathParameters["id"]!;
                  return MyPlaceDetailScreen(
                    placeSubscriptionId: placeSubscriptionId,
                    onAlertPressed: (String alertId, String subscriptionId) =>
                        context.push('/alerts/$alertId/$subscriptionId'),
                    onAlertUpdateThreadPressed: () =>
                        context.push('/alerts/update/'),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/alerts',
            redirect: (context, state) => null,
            routes: [
              GoRoute(
                path: ':id/:subscriptionId',
                builder: (context, state) {
                  String id = state.pathParameters["id"]!;
                  String subscriptionId =
                      state.pathParameters["subscriptionId"]!;
                  return DetailScreen(
                    warningFPASIdentifer: id,
                    subscriptionId: subscriptionId,
                  );
                },
              ),
              GoRoute(
                path: 'update',
                builder: (context, state) => AlertUpdateThreadView(
                  onAlertPressed: (fpasAlertId, subscriptionId) =>
                      context.go('/alerts/$fpasAlertId/$subscriptionId'),
                  onAlertUpdateThreadPressed: () =>
                      context.go('/alerts/update'),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
);
