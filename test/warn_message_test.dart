import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/class/class_area.dart';
import 'package:foss_warn/class/class_info.dart';
import 'package:foss_warn/class/class_references.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/enums/category.dart';
import 'package:foss_warn/enums/certainty.dart';
import 'package:foss_warn/enums/message_type.dart';
import 'package:foss_warn/enums/response_type.dart';
import 'package:foss_warn/enums/scope.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/enums/status.dart';
import 'package:foss_warn/enums/urgency.dart';

WarnMessage buildAlert({
  bool notified = false,
  bool read = false,
  bool isUpdateOfAlreadyNotifiedWarning = false,
  bool hideWarningBecauseThereIsANewerVersion = false,
  List<ResponseType>? responseType = const [ResponseType.monitor],
  String? web = "https://example.org",
  String? contact = "+49 69 8062 0",
}) {
  return WarnMessage(
    fpasId: "fpas-1",
    identifier: "identifier-1",
    placeId: "place-1",
    publisher: "",
    sender: "sender@example.org",
    sent: "2026-08-19T10:00:00+02:00",
    status: Status.actual,
    messageType: MessageType.update,
    scope: Scope.public,
    notified: notified,
    read: read,
    isUpdateOfAlreadyNotifiedWarning: isUpdateOfAlreadyNotifiedWarning,
    hideWarningBecauseThereIsANewerVersion:
        hideWarningBecauseThereIsANewerVersion,
    references: References(
      sender: "sender@example.org",
      identifier: const ["identifier-0"],
      send: "2026-08-19T09:00:00+02:00",
    ),
    info: [
      Info(
        language: "de-DE",
        category: const [Category.met],
        event: "GEWITTER",
        responseType: responseType,
        urgency: Urgency.immediate,
        severity: Severity.severe,
        certainty: Certainty.likely,
        headline: "Amtliche WARNUNG vor GEWITTER",
        description: "Es treten Gewitter auf.",
        instruction: "Vorsicht.",
        web: web,
        contact: contact,
        area: [
          Area(
            areaDesc: "Kreis Musterstadt",
            geoJson: jsonEncode({
              "type": "FeatureCollection",
              "features": [
                {
                  "type": "Feature",
                  "geometry": {
                    "type": "Polygon",
                    "coordinates": [
                      [
                        [8.0, 50.0],
                        [9.0, 50.0],
                        [9.0, 51.0],
                        [8.0, 50.0],
                      ],
                    ],
                  },
                  "properties": {"prop0": "value0"},
                },
              ],
            }),
          ),
        ],
      ),
    ],
  );
}

/// Serialize like the alert cache does and read the result back.
WarnMessage roundTrip(WarnMessage alert) {
  final encoded = jsonEncode(alert.toJson());
  final decoded = jsonDecode(encoded) as Map<String, dynamic>;
  return WarnMessage.fromJsonFromStorage(decoded);
}

void main() {
  group('storage round trip', () {
    test('keeps the read and notified state', () {
      final restored = roundTrip(buildAlert(notified: true, read: true));

      expect(restored.notified, isTrue);
      expect(restored.read, isTrue);
    });

    test('keeps the update and superseded flags', () {
      // Regression test: both flags were written by toJson but never read
      // back, so superseded alerts reappeared after every restart and updates
      // were notified again at full severity.
      final restored = roundTrip(
        buildAlert(
          isUpdateOfAlreadyNotifiedWarning: true,
          hideWarningBecauseThereIsANewerVersion: true,
        ),
      );

      expect(restored.isUpdateOfAlreadyNotifiedWarning, isTrue);
      expect(restored.hideWarningBecauseThereIsANewerVersion, isTrue);
    });

    test('defaults the flags to false when they are absent', () {
      final json = buildAlert().toJson()
        ..remove('notified')
        ..remove('read')
        ..remove('isUpdateOfAlreadyNotifiedWarning')
        ..remove('hideWarningBecauseThereIsANewerVersion');
      final restored = WarnMessage.fromJsonFromStorage(
        jsonDecode(jsonEncode(json)) as Map<String, dynamic>,
      );

      expect(restored.notified, isFalse);
      expect(restored.read, isFalse);
      expect(restored.isUpdateOfAlreadyNotifiedWarning, isFalse);
      expect(restored.hideWarningBecauseThereIsANewerVersion, isFalse);
    });

    test('keeps identity, references and the info block', () {
      final restored = roundTrip(buildAlert());

      expect(restored.fpasId, "fpas-1");
      expect(restored.placeId, "place-1");
      expect(restored.identifier, "identifier-1");
      expect(restored.sender, "sender@example.org");
      expect(restored.status, Status.actual);
      expect(restored.messageType, MessageType.update);
      expect(restored.scope, Scope.public);
      expect(restored.references?.identifier, ["identifier-0"]);

      final info = restored.info.single;
      expect(info.category, [Category.met]);
      expect(info.severity, Severity.severe);
      expect(info.urgency, Urgency.immediate);
      expect(info.certainty, Certainty.likely);
      expect(info.headline, "Amtliche WARNUNG vor GEWITTER");
      expect(info.instruction, "Vorsicht.");
    });

    test('keeps the responseType instead of throwing on it', () {
      // toJson used to hand the enum object to jsonEncode and fromJson used to
      // assign the resulting string straight back to a ResponseType? field.
      final restored = roundTrip(buildAlert());

      expect(restored.info.single.responseType, [ResponseType.monitor]);
    });

    test('keeps the polygon of the area', () {
      final restored = roundTrip(buildAlert());
      final geoJson =
          jsonDecode(restored.info.single.area.single.geoJson) as Map;

      expect(restored.info.single.area.single.description, "Kreis Musterstadt");
      expect(geoJson["features"], hasLength(1));
    });

    test('keeps absent optional fields absent', () {
      final restored = roundTrip(
        buildAlert(responseType: null, web: null, contact: null),
      );

      expect(restored.info.single.web, isNull);
      expect(restored.info.single.contact, isNull);
      // An absent responseType parses to an empty list
      expect(restored.info.single.responseType, []);
    });
  });

  group('equality', () {
    test('alerts are equal per fpas id and place id', () {
      final alert = buildAlert();

      expect(alert == alert.copyWith(read: true), isTrue);
      expect(alert.hashCode, alert.copyWith(read: true).hashCode);
    });

    test('the same alert for two places is not equal', () {
      final first = buildAlert();
      final second = WarnMessage(
        fpasId: first.fpasId,
        identifier: first.identifier,
        placeId: "place-2",
        publisher: first.publisher,
        sender: first.sender,
        sent: first.sent,
        status: first.status,
        messageType: first.messageType,
        scope: first.scope,
        info: first.info,
      );

      expect(first == second, isFalse);
    });
  });
}
