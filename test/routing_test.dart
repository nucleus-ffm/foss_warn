import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Mirrors the route tree of `lib/routes.dart`: one top level route with
/// relatively declared sub-routes, plus a top level redirect that sends first
/// time users to the introduction.
///
/// The redirect result is a *location*, not a route path, so it has to be
/// absolute even though the sub-routes themselves are declared relative.
GoRouter buildRouter({
  required bool showWelcomeScreen,
  required String introductionLocation,
  bool guardIntroduction = true,
}) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (showWelcomeScreen &&
          (!guardIntroduction || state.uri.path != '/introduction')) {
        return introductionLocation;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Text('home'),
        routes: [
          GoRoute(
            path: 'introduction',
            builder: (context, state) => const Text('introduction'),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const Text('settings'),
            routes: [
              GoRoute(
                path: 'notifications',
                builder: (context, state) => const Text('notifications'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Future<void> pumpRouter(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pump();
}

void main() {
  testWidgets('a first start lands on the introduction', (tester) async {
    final router = buildRouter(
      showWelcomeScreen: true,
      introductionLocation: '/introduction',
    );

    await pumpRouter(tester, router);

    expect(tester.takeException(), isNull);
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/introduction',
    );
    expect(find.text('introduction'), findsOneWidget);
  });

  testWidgets('a returning user lands on the home view', (tester) async {
    final router = buildRouter(
      showWelcomeScreen: false,
      introductionLocation: '/introduction',
    );

    await pumpRouter(tester, router);

    expect(tester.takeException(), isNull);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/');
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('a relative redirect location never resolves', (tester) async {
    // Regression test: returning "introduction" instead of "/introduction"
    // makes go_router fail to match the location
    // (`uri.path.startsWith(newMatchedLocation)` assertion in match.dart), so
    // the app renders nothing on first start.
    final router = buildRouter(
      showWelcomeScreen: true,
      introductionLocation: 'introduction',
    );

    await pumpRouter(tester, router);

    expect(tester.takeException(), isNotNull);
    expect(find.text('introduction'), findsNothing);
  });

  testWidgets('relatively declared sub-routes resolve', (tester) async {
    final router = buildRouter(
      showWelcomeScreen: false,
      introductionLocation: '/introduction',
    );

    await pumpRouter(tester, router);
    router.go('/settings/notifications');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/settings/notifications',
    );
    expect(find.text('notifications'), findsOneWidget);
  });
}
