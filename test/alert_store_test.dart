import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/class/class_references.dart';
import 'package:foss_warn/enums/message_type.dart';
import 'package:foss_warn/enums/scope.dart';
import 'package:foss_warn/enums/sorting_categories.dart';
import 'package:foss_warn/enums/status.dart';
import 'package:foss_warn/services/warnings.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

WarnMessage buildAlert(String id, {bool read = false}) => WarnMessage(
      fpasId: id,
      identifier: id,
      placeId: "place-1",
      publisher: "",
      sender: "sender@example.org",
      sent: "2026-08-19T10:00:00+02:00",
      status: Status.actual,
      messageType: MessageType.alert,
      scope: Scope.public,
      read: read,
      info: const [],
    );

/// The alerts as they are stored on disk.
List<String> persistedAlertIds() {
  final raw = SharedPreferencesState.instance.getString("cachedAlerts");
  if (raw == null) return [];
  return (jsonDecode(raw) as List<dynamic>)
      .map((alert) => (alert as Map<String, dynamic>)["fpasId"] as String)
      .toList();
}

ProviderContainer buildContainer() {
  final container = ProviderContainer(
    overrides: [
      // the store must not depend on the network for these tests
      alertsFutureProvider.overrideWith((ref) async {}),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    await SharedPreferencesState.initialize();
  });

  setUp(() async {
    await SharedPreferencesState.instance.clear();
  });

  group('store lifecycle', () {
    test('a write does not dispose the notifier that performed it', () async {
      // Regression test: the store used to watch the whole user preferences
      // object while its own write updated that object, so saving an alert
      // disposed and recreated the notifier mid-call. Anything holding the
      // notifier across a write then failed with
      // "Tried to use WarningService after `dispose` was called".
      final container = buildContainer();
      final service = container.read(processedAlertsProvider.notifier);

      service.updateAlert(buildAlert("a"));

      expect(service.mounted, isTrue);
      expect(
        identical(container.read(processedAlertsProvider.notifier), service),
        isTrue,
      );

      // the same instance keeps working for a whole batch
      service.updateAlert(buildAlert("b"));
      service.updateAlert(buildAlert("c"));

      expect(
        container.read(processedAlertsProvider).map((a) => a.fpasId),
        ["a", "b", "c"],
      );
    });

    test('an unrelated preference change keeps the alerts', () async {
      final container = buildContainer();
      container.read(processedAlertsProvider.notifier).updateAlert(
            buildAlert("a"),
          );

      await container
          .read(userPreferencesProvider.notifier)
          .setShowUpdateDialog(true);

      expect(
        container.read(processedAlertsProvider).map((a) => a.fpasId),
        ["a"],
      );
      expect(
        identical(
          container.read(processedAlertsProvider.notifier),
          container.read(processedAlertsProvider.notifier),
        ),
        isTrue,
      );
    });
  });

  group('persistence', () {
    test('writes every change to disk', () async {
      final container = buildContainer();
      final service = container.read(processedAlertsProvider.notifier);

      service.updateAlert(buildAlert("a"));
      service.updateAlert(buildAlert("b"));
      await Future<void>.delayed(Duration.zero);

      expect(persistedAlertIds(), ["a", "b"]);
    });

    test('reads the cache back on a fresh start', () async {
      final first = buildContainer();
      first.read(processedAlertsProvider.notifier).updateAlert(
            buildAlert("a", read: true),
          );
      await Future<void>.delayed(Duration.zero);

      // a new container is what a restarted app sees
      final second = buildContainer();
      final restored = second.read(processedAlertsProvider);

      expect(restored.map((a) => a.fpasId), ["a"]);
      expect(restored.single.read, isTrue);
    });

    test('deleting an alert also removes it from disk', () async {
      final container = buildContainer();
      final service = container.read(processedAlertsProvider.notifier);
      service.updateAlert(buildAlert("a"));
      service.updateAlert(buildAlert("b"));

      service.deleteAlert(buildAlert("a"));
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(processedAlertsProvider).map((a) => a.fpasId),
        ["b"],
      );
      expect(persistedAlertIds(), ["b"]);
    });

    test('deleteAllAlerts clears the list and the cache', () async {
      final container = buildContainer();
      final service = container.read(processedAlertsProvider.notifier);
      service.updateAlert(buildAlert("a"));

      service.deleteAllAlerts();
      await Future<void>.delayed(Duration.zero);

      expect(container.read(processedAlertsProvider), isEmpty);
      expect(persistedAlertIds(), isEmpty);
    });

    test('resetting the read state is persisted too', () async {
      final container = buildContainer();
      final service = container.read(processedAlertsProvider.notifier);
      service.updateAlert(buildAlert("a", read: true));

      service.resetReadAndNotificationStatusForAllWarnings();
      await Future<void>.delayed(Duration.zero);

      expect(container.read(processedAlertsProvider).single.read, isFalse);

      final restarted = buildContainer();
      expect(restarted.read(processedAlertsProvider).single.read, isFalse);
    });
  });

  group('alertsProvider', () {
    test('reflects a change of the store', () async {
      final container = buildContainer();
      expect(container.read(alertsProvider), isEmpty);

      container
          .read(processedAlertsProvider.notifier)
          .updateAlert(buildAlert("a"));

      expect(container.read(alertsProvider).map((a) => a.fpasId), ["a"]);
    });

    test('marks a superseded alert for the views', () async {
      final container = buildContainer();
      final service = container.read(processedAlertsProvider.notifier);
      service.updateAlert(buildAlert("old"));
      service.updateAlert(
        WarnMessage(
          fpasId: "new",
          identifier: "new",
          placeId: "place-1",
          publisher: "",
          sender: "sender@example.org",
          sent: "2026-08-19T11:00:00+02:00",
          status: Status.actual,
          messageType: MessageType.update,
          scope: Scope.public,
          references: References.fromString(
            "sender@example.org,old,2026-08-19T10:00:00+02:00",
          ),
          info: const [],
        ),
      );

      final alerts = container.read(alertsProvider);

      expect(
        alerts
            .firstWhere((a) => a.fpasId == "old")
            .hideWarningBecauseThereIsANewerVersion,
        isTrue,
        reason: "the derived flag has to reach the list the views render",
      );
      // the store itself keeps the untouched alert
      expect(
        container
            .read(processedAlertsProvider)
            .firstWhere((a) => a.fpasId == "old")
            .hideWarningBecauseThereIsANewerVersion,
        isFalse,
      );
    });

    test('applies the sorting preference', () async {
      final container = buildContainer();
      final service = container.read(processedAlertsProvider.notifier);
      service.updateAlert(buildAlert("old"));
      service.updateAlert(
        WarnMessage(
          fpasId: "new",
          identifier: "new",
          placeId: "place-1",
          publisher: "",
          sender: "sender@example.org",
          sent: "2026-08-20T10:00:00+02:00",
          status: Status.actual,
          messageType: MessageType.alert,
          scope: Scope.public,
          info: const [],
        ),
      );

      await container
          .read(userPreferencesProvider.notifier)
          .setSortWarningsBy(SortingCategories.data);

      expect(
        container.read(alertsProvider).map((a) => a.fpasId),
        ["new", "old"],
      );
    });
  });
}
