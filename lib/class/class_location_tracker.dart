import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_bounding_box.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/extensions/list.dart';

import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/subscription_handler.dart';
import 'package:foss_warn/widgets/dialogs/generic_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../class/class_fpas_place.dart';

final locationTrackerProvider = Provider<LocationTracker>((ref) {
  return LocationTracker(ref: ref);
});

/// This class features method to subscribe for location updates
/// and simple method for getting the current location
class LocationTracker {
  Ref ref;

  LocationTracker({required this.ref});

  LocationSettings get locationSettings {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10000, // 10km
      );
    } else {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10000, // 10km
      );
    }
  }

  /// init the background location tracking
  /// this will check if we have the right permissions
  void init(BuildContext context) {
    checkLocationPermission(context);
  }

  /// Check if we have the right permission and if not, show a dialog and ask
  /// for the right permission,
  ///
  /// return true if we have the right permission, false if not
  static Future<bool> checkLocationPermission(BuildContext context) async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (!context.mounted) return false;
    var localisation = context.localizations;

    // permission denied, show dialog and ask for permission
    if (permission == LocationPermission.denied) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return GenericDialog(
            title: localisation.location_tracking_permission_dialog_title,
            content: localisation.location_tracking_permission_dialog_body,
          );
        },
      );
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!context.mounted) return false;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return GenericDialog(
              title: localisation
                  .location_tracking_permission_missing_dialog_title,
              content:
                  localisation.location_tracking_permission_missing_dialog_body,
            );
          },
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, inform user
      if (!context.mounted) return false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GenericDialog(
            title: localisation
                .location_tracking_permission_missing_forever_dialog_title,
            content: localisation
                .location_tracking_permission_missing_forever_dialog_body,
          );
        },
      );
      await Geolocator.openLocationSettings();
      return false;
    }

    // we can access the location while the app is in use.
    // Request the user to select always in the settings
    if (permission == LocationPermission.whileInUse) {
      if (!context.mounted) return false;
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return GenericDialog(
            title: localisation
                .location_tracking_permission_background_dialog_title,
            content: localisation
                .location_tracking_permission_background_dialog_body,
          );
        },
      );
      await Geolocator.openAppSettings();

      if (!context.mounted) return false;
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return GenericDialog(
            title:
                localisation.location_tracking_permission_confirm_changed_title,
            content:
                localisation.location_tracking_permission_confirm_changed_body,
          );
        },
      );
    }

    permission = await Geolocator.checkPermission();
    // we still have not the right permission to operate in background
    // inform the user, that the app can not work as expected
    if (!context.mounted) return false;
    if (permission != LocationPermission.always) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return GenericDialog(
            title: localisation
                .location_tracking_permission_only_while_using_dialog_title,
            content: localisation
                .location_tracking_permission_only_while_using_dialog_body,
          );
        },
      );
      return false;
    }
    return true;
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // Check if location services are enabled
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are denied');
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
    } catch (e) {
      return await Geolocator.getLastKnownPosition();
    }
  }

  /// Check if there is a subscription for the current location
  /// and if yes unsubscribe and remove that place
  Future<void> removeCurrentLocationSubscription() async {
    List<Place> places = await ref.read(cachedPlacesProvider.future);

    Place? currentLocationPlace = places
        .firstWhereOrNull((places) => places.isForCurrentLocation ?? false);

    // if we already subscribed for a place, remove this subscription first
    if (currentLocationPlace != null) {
      var alertAPi = ref.read(alertApiProvider);
      alertAPi.unregisterArea(
        subscriptionId: currentLocationPlace.subscriptionId!,
      );
      await ref.read(myPlacesProvider.notifier).remove(currentLocationPlace);
    }
  }

  /// subscribe for the current location
  Future<void> subscribeForCurrentLocation() async {
    // subscribe for current location
    Position? position = await determinePosition();
    if (position != null) {
      await removeCurrentLocationSubscription();
      LatLng center = LatLng(position.latitude, position.longitude);

      BoundingBox boundingBox =
          BoundingBox.buildAroundCenterPoint(center, 5, 4);

      await subscribeForAreaInBackground(
        boundingBox: boundingBox,
        selectedPlaceName: "Current Location",
        ref: ref,
        isForCurrentLocation: true,
      );
    }
  }
}
