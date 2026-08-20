import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/class/class_bounding_box.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/warnings.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

Place buildPlace(String id, {String? subscriptionId}) => Place(
      id: id,
      name: "Place $id",
      subscriptionId: subscriptionId ?? "sub-$id",
      boundingBox: BoundingBox(
        minLatLng: const LatLng(1, 2),
        maxLatLng: const LatLng(3, 4),
      ),
    );

Future<void> seedPlaces(List<Place> places) async {
  await SharedPreferencesState.instance
      .setString("MyPlacesListAsJson", jsonEncode(places));
}

/// A server that has already forgotten every subscription - exactly what it
/// answers right after the client unsubscribed.
MockClient unknownSubscriptionServer({Future<void>? delayResponse}) =>
    MockClient((request) async {
      if (delayResponse != null) await delayResponse;
      return http.Response("unknown subscription", 400);
    });

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

  test('a deleted place stays deleted when it was the only one', () async {
    await seedPlaces([buildPlace("a")]);
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // let the places load from disk
    await container.read(cachedPlacesProvider.future);
    expect(container.read(myPlacesProvider), hasLength(1));

    // the user deletes the place, the app unsubscribed it on the server
    await container.read(myPlacesProvider.notifier).remove(buildPlace("a"));
    expect(container.read(myPlacesProvider), isEmpty);

    // the next polling cycle must not ask for it, and must not bring it back
    final requestedSubscriptions = <String>[];
    await http.runWithClient(
      () => container.read(alertsFutureProvider.future),
      () => MockClient((request) async {
        requestedSubscriptions
            .add(request.url.queryParameters["subscription_id"] ?? "");
        return http.Response("unknown subscription", 400);
      }),
    );

    expect(
      requestedSubscriptions,
      isEmpty,
      reason: "there is nothing left to poll for",
    );
    expect(
      container.read(myPlacesProvider),
      isEmpty,
      reason: "the deleted place must not reappear",
    );
    expect(
      jsonDecode(
        SharedPreferencesState.instance.getString("MyPlacesListAsJson") ?? "[]",
      ),
      isEmpty,
      reason: "and it must not be written back to disk either",
    );
  });

  test('a place deleted while a fetch is in flight stays deleted', () async {
    await seedPlaces([buildPlace("a"), buildPlace("b")]);
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(cachedPlacesProvider.future);
    expect(container.read(myPlacesProvider), hasLength(2));

    // hold the server response until the place was deleted
    final serverAnswers = Completer<void>();
    final fetch = http.runWithClient(
      () => container.read(alertsFutureProvider.future),
      () => unknownSubscriptionServer(delayResponse: serverAnswers.future),
    );

    await container.read(myPlacesProvider.notifier).remove(buildPlace("a"));
    serverAnswers.complete();
    await fetch;

    expect(
      container.read(myPlacesProvider).map((place) => place.id),
      ["b"],
      reason: "the place deleted during the fetch must not come back",
    );
  });

  test('a cold start still fetches for the places on disk', () async {
    // The background poll runs in a fresh isolate where the places are not
    // loaded yet: the fetch has to wait for them instead of seeing an empty
    // list and doing nothing.
    await seedPlaces([buildPlace("a")]);
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final requestedSubscriptions = <String>[];
    await http.runWithClient(
      () => container.read(alertsFutureProvider.future),
      () => MockClient((request) async {
        requestedSubscriptions
            .add(request.url.queryParameters["subscription_id"] ?? "");
        return http.Response(jsonEncode(<String>[]), 200);
      }),
    );

    expect(requestedSubscriptions, ["sub-a"]);
    expect(container.read(myPlacesProvider), hasLength(1));
  });

  test('an expired subscription is still marked on a place we kept', () async {
    await seedPlaces([buildPlace("a")]);
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(cachedPlacesProvider.future);

    await http.runWithClient(
      () => container.read(alertsFutureProvider.future),
      unknownSubscriptionServer,
    );

    final places = container.read(myPlacesProvider);
    expect(places, hasLength(1));
    expect(
      places.single.isExpired,
      isTrue,
      reason: "a subscription the server rejects has to be flagged",
    );
  });
}
