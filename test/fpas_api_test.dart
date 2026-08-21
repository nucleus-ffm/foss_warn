import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/class/class_app_state.dart';
import 'package:foss_warn/class/class_bounding_box.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/enums/message_type.dart';
import 'package:foss_warn/enums/response_type.dart';
import 'package:foss_warn/enums/scope.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/enums/status.dart';
import 'package:foss_warn/enums/urgency.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/services/api_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

import 'helpers/cap_fixtures.dart';
import 'helpers/test_preferences.dart';

/// Runs [body] with every top level `http` call served by [handler].
Future<T> withMockedHttp<T>(
  Future<T> Function() body,
  Future<http.Response> Function(http.Request request) handler,
) {
  return http.runWithClient(body, () => MockClient(handler));
}

AppState buildAppState({bool reSubscriptionInProgress = false}) => AppState(
      error: false,
      areWarningsFromCache: false,
      isFirstFetch: false,
      pushNotificationSetupError: false,
      reSubscriptionInProgress: reSubscriptionInProgress,
      unifiedPushRegistered: false,
    );

void main() {
  final api = FPASApi(
    userPreferences: createUserPreferences(
      fossPublicAlertServerUrl: "alerts.example.org",
    ),
  );

  group('getAlertsForArea', () {
    test('sends the bounding box as string query parameters', () async {
      // Regression test: passing the doubles straight into Uri.https throws
      // `TypeError: type 'double' is not a subtype of type 'Iterable'`, which
      // used to break every alert lookup for places without a subscription.
      late Uri requestedUrl;

      final result = await withMockedHttp(
        () => api.getAlertsForArea(
          placeId: "place-1",
          boundingBox: BoundingBox(
            minLatLng: const LatLng(-48.8767, -124.3933),
            maxLatLng: const LatLng(-47.8767, -122.3933),
          ),
        ),
        (request) async {
          requestedUrl = request.url;
          return http.Response(jsonEncode(["alert-a", "alert-b"]), 200);
        },
      );

      expect(requestedUrl.scheme, "https");
      expect(requestedUrl.host, "alerts.example.org");
      expect(requestedUrl.path, "/alert/area");
      expect(requestedUrl.queryParameters, {
        "min_lat": "-48.8767",
        "max_lat": "-47.8767",
        "min_lon": "-124.3933",
        "max_lon": "-122.3933",
      });
      expect(
        result,
        [
          (placeId: "place-1", alertId: "alert-a"),
          (placeId: "place-1", alertId: "alert-b"),
        ],
      );
    });

    test('throws UndefinedServerError for a non 200 response', () async {
      await expectLater(
        withMockedHttp(
          () => api.getAlertsForArea(
            placeId: "place-1",
            boundingBox: BoundingBox(
              minLatLng: const LatLng(1, 2),
              maxLatLng: const LatLng(3, 4),
            ),
          ),
          (request) async => http.Response("nope", 500),
        ),
        throwsA(isA<UndefinedServerError>()),
      );
    });
  });

  group('getAlertsForSubscription', () {
    test('returns the alert ids for the subscription', () async {
      late Uri requestedUrl;

      final result = await withMockedHttp(
        () => api.getAlertsForSubscription(
          placeId: "place-1",
          subscriptionId: "sub-1",
          appState: buildAppState(),
        ),
        (request) async {
          requestedUrl = request.url;
          return http.Response(jsonEncode(["alert-a"]), 200);
        },
      );

      expect(requestedUrl.path, "/alert/all");
      expect(requestedUrl.queryParameters, {"subscription_id": "sub-1"});
      expect(result, [(placeId: "place-1", alertId: "alert-a")]);
    });

    test('throws InvalidSubscriptionError on status code 400', () async {
      await expectLater(
        withMockedHttp(
          () => api.getAlertsForSubscription(
            placeId: "place-1",
            subscriptionId: "gone",
            appState: buildAppState(),
          ),
          (request) async => http.Response("invalid", 400),
        ),
        throwsA(isA<InvalidSubscriptionError>()),
      );
    });

    test('does not hit the server while resubscribing', () async {
      var requestCount = 0;

      final result = await withMockedHttp(
        () => api.getAlertsForSubscription(
          placeId: "place-1",
          subscriptionId: "sub-1",
          appState: buildAppState(reSubscriptionInProgress: true),
        ),
        (request) async {
          requestCount++;
          return http.Response(jsonEncode(["alert-a"]), 200);
        },
      );

      expect(result, isEmpty);
      expect(requestCount, 0);
    });
  });

  group('getAlerts', () {
    test('uses the area endpoint when the place has no subscription', () async {
      late Uri requestedUrl;

      await withMockedHttp(
        () => api.getAlerts(
          place: Place(
            id: "place-1",
            name: "Local only",
            boundingBox: BoundingBox(
              minLatLng: const LatLng(1, 2),
              maxLatLng: const LatLng(3, 4),
            ),
          ),
          appState: buildAppState(),
        ),
        (request) async {
          requestedUrl = request.url;
          return http.Response(jsonEncode(<String>[]), 200);
        },
      );

      expect(requestedUrl.path, "/alert/area");
    });

    test('uses the subscription endpoint when a subscription exists', () async {
      late Uri requestedUrl;

      await withMockedHttp(
        () => api.getAlerts(
          place: Place(
            id: "place-1",
            name: "Subscribed",
            subscriptionId: "sub-1",
            boundingBox: BoundingBox(
              minLatLng: const LatLng(1, 2),
              maxLatLng: const LatLng(3, 4),
            ),
          ),
          appState: buildAppState(),
        ),
        (request) async {
          requestedUrl = request.url;
          return http.Response(jsonEncode(<String>[]), 200);
        },
      );

      expect(requestedUrl.path, "/alert/all");
    });
  });

  group('getAlertDetail', () {
    test('parses a full CAP alert including responseType', () async {
      // Regression test: `responseType` used to be assigned straight from the
      // decoded XML, which threw a TypeError for every alert that carries it.
      final alert = await withMockedHttp(
        () => api.getAlertDetail(alertId: "fpas-1", placeId: "place-1"),
        (request) async {
          expect(request.url.path, "/alert/fpas-1");
          return http.Response.bytes(utf8.encode(capAlertXml), 200);
        },
      );

      expect(alert.fpasId, "fpas-1");
      expect(alert.placeId, "place-1");
      expect(alert.identifier, "2.49.0.0.276.0.DWD.PVW.1234");
      expect(alert.sender, "opendata@dwd.de");
      expect(alert.status, Status.actual);
      expect(alert.messageType, MessageType.update);
      expect(alert.scope, Scope.public);

      expect(alert.info, hasLength(1));
      final info = alert.info.first;
      expect(info.responseType, [ResponseType.monitor]);
      expect(info.severity, Severity.severe);
      expect(info.urgency, Urgency.immediate);
      expect(info.headline, "Amtliche WARNUNG vor GEWITTER");
      expect(info.web, "https://www.wettergefahren.de");
      expect(info.contact, "+49 69 8062 0");

      expect(alert.references, isNotNull);
      expect(alert.references!.identifier, [
        "2.49.0.0.276.0.DWD.PVW.1111",
        "2.49.0.0.276.0.DWD.PVW.2222",
      ]);
    });

    test('parses an alert with responseType AllClear', () async {
      final alert = await withMockedHttp(
        () => api.getAlertDetail(alertId: "fpas-2", placeId: "place-1"),
        (request) async =>
            http.Response.bytes(utf8.encode(capAllClearAlertXml), 200),
      );

      expect(alert.info.first.responseType, [ResponseType.allclear]);
      expect(alert.messageType, MessageType.cancel);
    });

    test('parses a minimal alert without optional fields', () async {
      final alert = await withMockedHttp(
        () => api.getAlertDetail(alertId: "fpas-3", placeId: "place-1"),
        (request) async =>
            http.Response.bytes(utf8.encode(capMinimalAlertXml), 200),
      );

      final info = alert.info.first;
      expect(alert.references, isNull);
      expect(info.responseType, []);
      // A missing element must stay null so the detail view can hide the
      // section instead of rendering an empty one.
      expect(info.web, isNull);
      expect(info.contact, isNull);
      expect(info.instruction, isNull);
    });

    test('throws AlertUnavailableError on status code 404', () async {
      await expectLater(
        withMockedHttp(
          () => api.getAlertDetail(alertId: "gone", placeId: "place-1"),
          (request) async => http.Response("not found", 404),
        ),
        throwsA(isA<AlertUnavailableError>()),
      );
    });
  });

  group('fetchServerSettings', () {
    test('parses the server status', () async {
      final settings = await withMockedHttp(
        () => api.fetchServerSettings(),
        (request) async {
          expect(request.url.path, "/config/server_status");
          return http.Response(
            jsonEncode({
              "server_version": "1.2.3",
              "server_operator": "KDE",
              "privacy_notice": "https://example.org/privacy",
              "terms_of_service": "https://example.org/terms",
              "congestion_state": 0,
              "supported_push_services": {"UNIFIED_PUSH_ENCRYPTED": true},
            }),
            200,
          );
        },
      );

      expect(settings.url, "alerts.example.org");
      expect(settings.version, "1.2.3");
      expect(settings.supportedPushServices["UNIFIED_PUSH_ENCRYPTED"], isTrue);
    });

    test('throws UnreachableServerError for a non 200 response', () async {
      await expectLater(
        withMockedHttp(
          () => api.fetchServerSettings(),
          (request) async => http.Response("", 503),
        ),
        throwsA(isA<UnreachableServerError>()),
      );
    });
  });

  group('registerArea', () {
    test('sends the bounding box and the push endpoint', () async {
      late Map<String, dynamic> body;

      final result = await withMockedHttp(
        () => api.registerArea(
          boundingBox: BoundingBox(
            minLatLng: const LatLng(-48.8767, -124.3933),
            maxLatLng: const LatLng(-47.8767, -122.3933),
          ),
          unifiedPushEndpoint: "https://push.example.org/endpoint",
        ),
        (request) async {
          if (request.url.path == "/config/server_status") {
            return http.Response(
              jsonEncode({
                "server_version": "1.2.3",
                "server_operator": "KDE",
                "privacy_notice": "",
                "terms_of_service": "",
                "congestion_state": 0,
                "supported_push_services": <String, dynamic>{},
              }),
              200,
            );
          }
          body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              "subscription_id": "sub-42",
              "confirmation_id": "confirm-42",
            }),
            200,
          );
        },
      );

      expect(body["token"], "https://push.example.org/endpoint");
      expect(body["push_service"], "UNIFIED_PUSH");
      expect(body["min_lat"], "-48.8767");
      expect(body["max_lon"], "-122.3933");
      expect(result.subscriptionId, "sub-42");
      expect(result.confirmationId, "confirm-42");
    });
  });

  group('unregisterArea', () {
    test('accepts 200, 400 and 404 as terminal states', () async {
      for (final statusCode in [200, 400, 404]) {
        await withMockedHttp(
          () => api.unregisterArea(subscriptionId: "sub-1"),
          (request) async => http.Response("", statusCode),
        );
      }
    });

    test('throws UnregisterAreaError for other status codes', () async {
      await expectLater(
        withMockedHttp(
          () => api.unregisterArea(subscriptionId: "sub-1"),
          (request) async => http.Response("", 500),
        ),
        throwsA(isA<UnregisterAreaError>()),
      );
    });
  });
}
