import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/enums/alert_service.dart';
import 'package:foss_warn/enums/category.dart';
import 'package:foss_warn/enums/certainty.dart';
import 'package:foss_warn/enums/message_type.dart';
import 'package:foss_warn/enums/notification_channel.dart';
import 'package:foss_warn/enums/response_type.dart';
import 'package:foss_warn/enums/scope.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/enums/status.dart';
import 'package:foss_warn/enums/urgency.dart';

void main() {
  group('ResponseType', () {
    test('parses every CAP value, including AllClear', () {
      // CAP spells the values in CamelCase; AllClear is the one that a plain
      // `values.byName(value.toLowerCase())` lookup can silently miss.
      expect(ResponseType.fromJson("Shelter"), ResponseType.shelter);
      expect(ResponseType.fromJson("Evacuate"), ResponseType.evacuate);
      expect(ResponseType.fromJson("Prepare"), ResponseType.prepare);
      expect(ResponseType.fromJson("Execute"), ResponseType.execute);
      expect(ResponseType.fromJson("Avoid"), ResponseType.avoid);
      expect(ResponseType.fromJson("Monitor"), ResponseType.monitor);
      expect(ResponseType.fromJson("AllClear"), ResponseType.allclear);
      expect(ResponseType.fromJson("None"), ResponseType.none);
    });

    test('falls back to unknown for null and unexpected values', () {
      expect(ResponseType.fromJson(null), ResponseType.unknown);
      expect(ResponseType.fromJson(""), ResponseType.unknown);
      expect(ResponseType.fromJson("Assess"), ResponseType.unknown);
    });

    test('serializes back to the name it parses', () {
      for (final value in ResponseType.values) {
        expect(ResponseType.fromJson(value.toJson()), value);
      }
    });
  });

  group('Severity', () {
    test('parses the CAP values case insensitively', () {
      expect(Severity.fromJson("Extreme"), Severity.extreme);
      expect(Severity.fromJson("severe"), Severity.severe);
      expect(Severity.fromJson("MODERATE"), Severity.moderate);
      expect(Severity.fromJson("Minor"), Severity.minor);
      expect(Severity.fromJson("Unknown"), Severity.unknown);
    });

    test('falls back to unknown for null and unexpected values', () {
      expect(Severity.fromJson(null), Severity.unknown);
      expect(Severity.fromJson("catastrophic"), Severity.unknown);
    });

    test('orders from most to least severe', () {
      expect(Severity.getIndexFromSeverity(Severity.extreme), 0);
      expect(Severity.getIndexFromSeverity(Severity.severe), 1);
      expect(Severity.getIndexFromSeverity(Severity.moderate), 2);
      expect(Severity.getIndexFromSeverity(Severity.minor), 3);
    });

    test('round trips through json', () {
      for (final value in Severity.values) {
        expect(Severity.fromJson(value.toJson()), value);
      }
    });
  });

  group('NotificationChannel', () {
    test('maps an unknown severity to the middle channel', () {
      expect(
        NotificationChannel.fromSeverity(Severity.unknown),
        NotificationChannel.moderate,
      );
    });

    test('gives every severity its own channel id', () {
      final ids = NotificationChannel.values.map((c) => c.channelId).toList();

      expect(ids.toSet(), hasLength(ids.length));
      expect(
        NotificationChannel.fromSeverity(Severity.extreme).channelId,
        "de.nucleus.foss_warn.notifications_extreme",
      );
    });
  });

  group('other CAP enums', () {
    test('Category parses single values and lists', () {
      expect(Category.fromString("Met"), Category.met);
      expect(Category.fromString("CBRNE"), Category.cbrne);
      expect(Category.fromString("nonsense"), Category.other);
      expect(
        Category.categoryListFromJson(["Met", "Geo"]),
        [Category.met, Category.geo],
      );
      expect(Category.categoryListFromJson(null), isEmpty);
    });

    test('MessageType, Status, Scope, Urgency and Certainty parse CAP values',
        () {
      expect(MessageType.fromJson("Update"), MessageType.update);
      expect(MessageType.fromJson(null), MessageType.unknown);
      expect(Status.fromJson("Actual"), Status.actual);
      expect(Status.fromJson("nonsense"), Status.unknown);
      expect(Scope.fromJson("Public"), Scope.public);
      expect(Scope.fromJson(null), Scope.unknown);
      expect(Urgency.fromJson("Immediate"), Urgency.immediate);
      expect(Urgency.fromJson("nonsense"), Urgency.unknown);
      expect(Certainty.fromJson("Likely"), Certainty.likely);
      expect(Certainty.fromJson(null), Certainty.unknown);
    });

    test('AlertService round trips through json', () {
      for (final value in AlertService.values) {
        expect(AlertService.fromJson(value.toJson()), value);
      }
    });
  });
}
