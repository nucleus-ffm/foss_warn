import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/class/class_info.dart';
import 'package:foss_warn/class/class_references.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/enums/category.dart';
import 'package:foss_warn/enums/certainty.dart';
import 'package:foss_warn/enums/message_type.dart';
import 'package:foss_warn/enums/scope.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/enums/sorting_categories.dart';
import 'package:foss_warn/enums/status.dart';
import 'package:foss_warn/enums/urgency.dart';
import 'package:foss_warn/services/warnings.dart';

WarnMessage buildAlert({
  required String identifier,
  String? fpasId,
  String placeId = "place-1",
  String sender = "sender@example.org",
  String sent = "2026-08-19T10:00:00+02:00",
  Severity severity = Severity.severe,
  bool notified = false,
  List<String>? references,
  bool withInfo = true,
}) {
  return WarnMessage(
    fpasId: fpasId ?? identifier,
    identifier: identifier,
    placeId: placeId,
    publisher: "",
    sender: sender,
    sent: sent,
    status: Status.actual,
    messageType: references == null ? MessageType.alert : MessageType.update,
    scope: Scope.public,
    notified: notified,
    references: references == null
        ? null
        : References(
            sender: sender,
            identifier: references,
            send: "2026-08-19T09:00:00+02:00",
          ),
    info: [
      if (withInfo)
        Info(
          category: const [Category.met],
          event: "GEWITTER",
          urgency: Urgency.immediate,
          severity: severity,
          certainty: Certainty.likely,
          headline: "headline $identifier",
          description: "description",
          instruction: null,
          area: const [],
        ),
    ],
  );
}

WarnMessage byIdentifier(List<WarnMessage> alerts, String identifier) =>
    alerts.firstWhere((alert) => alert.identifier == identifier);

void main() {
  group('applyUpdateRelations - superseded alerts', () {
    test('marks the alert a newer alert references', () {
      final result = applyUpdateRelations([
        buildAlert(identifier: "old"),
        buildAlert(identifier: "new", references: ["old"]),
      ]);

      expect(
        byIdentifier(result, "old").hideWarningBecauseThereIsANewerVersion,
        isTrue,
      );
      expect(
        byIdentifier(result, "new").hideWarningBecauseThereIsANewerVersion,
        isFalse,
      );
    });

    test('marks every alert of a longer update chain but the newest', () {
      final result = applyUpdateRelations([
        buildAlert(identifier: "v1"),
        buildAlert(identifier: "v2", references: ["v1"]),
        buildAlert(identifier: "v3", references: ["v2"]),
      ]);

      expect(
        byIdentifier(result, "v1").hideWarningBecauseThereIsANewerVersion,
        isTrue,
      );
      expect(
        byIdentifier(result, "v2").hideWarningBecauseThereIsANewerVersion,
        isTrue,
      );
      expect(
        byIdentifier(result, "v3").hideWarningBecauseThereIsANewerVersion,
        isFalse,
      );
    });

    test('marks every referenced alert when one update replaces several', () {
      final result = applyUpdateRelations([
        buildAlert(identifier: "a"),
        buildAlert(identifier: "b"),
        buildAlert(identifier: "summary", references: ["a", "b"]),
      ]);

      expect(
        byIdentifier(result, "a").hideWarningBecauseThereIsANewerVersion,
        isTrue,
      );
      expect(
        byIdentifier(result, "b").hideWarningBecauseThereIsANewerVersion,
        isTrue,
      );
    });

    test('ignores references to alerts we do not have', () {
      final result = applyUpdateRelations([
        buildAlert(identifier: "new", references: ["never-seen"]),
      ]);

      expect(
        byIdentifier(result, "new").hideWarningBecauseThereIsANewerVersion,
        isFalse,
      );
    });

    test('unhides an alert once its newer version is gone', () {
      // The flag is persisted with the alert, so a stale true has to be
      // cleared - otherwise the alert stays invisible forever.
      final stale = buildAlert(identifier: "old")
          .copyWith(hideWarningBecauseThereIsANewerVersion: true);

      final result = applyUpdateRelations([stale]);

      expect(
        byIdentifier(result, "old").hideWarningBecauseThereIsANewerVersion,
        isFalse,
      );
    });

    test('hides the alert for every place it was fetched for', () {
      final result = applyUpdateRelations([
        buildAlert(identifier: "old", fpasId: "old", placeId: "place-1"),
        buildAlert(identifier: "old", fpasId: "old", placeId: "place-2"),
        buildAlert(identifier: "new", references: ["old"]),
      ]);

      final oldAlerts =
          result.where((alert) => alert.identifier == "old").toList();
      expect(oldAlerts, hasLength(2));
      expect(
        oldAlerts.every((a) => a.hideWarningBecauseThereIsANewerVersion),
        isTrue,
      );
    });
  });

  group('applyUpdateRelations - updates of notified alerts', () {
    test('an update of a notified alert is flagged as an update', () {
      final result = applyUpdateRelations([
        buildAlert(identifier: "old", notified: true),
        buildAlert(identifier: "new", references: ["old"]),
      ]);

      expect(
        byIdentifier(result, "new").isUpdateOfAlreadyNotifiedWarning,
        isTrue,
      );
    });

    test('an update of an alert we never notified about is not flagged', () {
      final result = applyUpdateRelations([
        buildAlert(identifier: "old"),
        buildAlert(identifier: "new", references: ["old"]),
      ]);

      expect(
        byIdentifier(result, "new").isUpdateOfAlreadyNotifiedWarning,
        isFalse,
      );
    });

    test('an update that raises the severity alerts again', () {
      final result = applyUpdateRelations([
        buildAlert(
          identifier: "old",
          severity: Severity.moderate,
          notified: true,
        ),
        buildAlert(
          identifier: "new",
          severity: Severity.extreme,
          references: ["old"],
        ),
      ]);

      expect(
        byIdentifier(result, "new").isUpdateOfAlreadyNotifiedWarning,
        isFalse,
        reason: "a more severe update has to reach the user again",
      );
    });

    test('an update that lowers the severity stays quiet', () {
      final result = applyUpdateRelations([
        buildAlert(
          identifier: "old",
          severity: Severity.extreme,
          notified: true,
        ),
        buildAlert(
          identifier: "new",
          severity: Severity.minor,
          references: ["old"],
        ),
      ]);

      expect(
        byIdentifier(result, "new").isUpdateOfAlreadyNotifiedWarning,
        isTrue,
      );
    });

    test('an alert without references is never an update', () {
      final result = applyUpdateRelations([buildAlert(identifier: "solo")]);

      expect(
        byIdentifier(result, "solo").isUpdateOfAlreadyNotifiedWarning,
        isFalse,
      );
    });
  });

  group('applyUpdateRelations - robustness', () {
    test('returns a new list and does not modify the input', () {
      final alerts = [
        buildAlert(identifier: "old"),
        buildAlert(identifier: "new", references: ["old"]),
      ];

      final result = applyUpdateRelations(alerts);

      expect(identical(result, alerts), isFalse);
      expect(alerts.first.hideWarningBecauseThereIsANewerVersion, isFalse);
      expect(result, hasLength(alerts.length));
    });

    test('handles an empty list', () {
      expect(applyUpdateRelations([]), isEmpty);
    });

    test('does not throw on an alert without an info block', () {
      // A CAP alert may arrive without <info>; it must not take the whole
      // list down with it.
      final result = applyUpdateRelations([
        buildAlert(identifier: "old", notified: true, withInfo: false),
        buildAlert(identifier: "new", references: ["old"], withInfo: false),
      ]);

      expect(result, hasLength(2));
      expect(
        byIdentifier(result, "old").hideWarningBecauseThereIsANewerVersion,
        isTrue,
      );
    });
  });

  group('sortAlerts', () {
    test('sorts by severity, most severe first', () {
      final sorted = sortAlerts(
        [
          buildAlert(identifier: "minor", severity: Severity.minor),
          buildAlert(identifier: "extreme", severity: Severity.extreme),
          buildAlert(identifier: "moderate", severity: Severity.moderate),
        ],
        SortingCategories.severity,
      );

      expect(
        sorted.map((alert) => alert.identifier),
        ["extreme", "moderate", "minor"],
      );
    });

    test('sorts by date, newest first', () {
      final sorted = sortAlerts(
        [
          buildAlert(identifier: "old", sent: "2026-08-18T10:00:00+02:00"),
          buildAlert(identifier: "new", sent: "2026-08-20T10:00:00+02:00"),
          buildAlert(identifier: "middle", sent: "2026-08-19T10:00:00+02:00"),
        ],
        SortingCategories.data,
      );

      expect(
        sorted.map((alert) => alert.identifier),
        ["new", "middle", "old"],
      );
    });

    test('sorts by source', () {
      final sorted = sortAlerts(
        [
          buildAlert(identifier: "a", sender: "aaa@example.org"),
          buildAlert(identifier: "c", sender: "ccc@example.org"),
          buildAlert(identifier: "b", sender: "bbb@example.org"),
        ],
        SortingCategories.source,
      );

      expect(sorted.map((alert) => alert.identifier), ["c", "b", "a"]);
    });

    test('returns a new list and keeps the input order', () {
      final alerts = [
        buildAlert(identifier: "minor", severity: Severity.minor),
        buildAlert(identifier: "extreme", severity: Severity.extreme),
      ];

      final sorted = sortAlerts(alerts, SortingCategories.severity);

      expect(identical(sorted, alerts), isFalse);
      expect(alerts.map((alert) => alert.identifier), ["minor", "extreme"]);
      expect(sorted.map((alert) => alert.identifier), ["extreme", "minor"]);
    });

    test('sorts an alert without an info block last', () {
      final sorted = sortAlerts(
        [
          buildAlert(identifier: "no info", withInfo: false),
          buildAlert(identifier: "minor", severity: Severity.minor),
        ],
        SortingCategories.severity,
      );

      expect(sorted.map((alert) => alert.identifier), ["minor", "no info"]);
    });
  });
}
