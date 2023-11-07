import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_NinaPlace.dart';
import 'package:foss_warn/main.dart';
import 'package:foss_warn/services/listHandler.dart';
import 'package:foss_warn/services/saveAndLoadSharedPreferences.dart';
import 'package:foss_warn/services/updateProvider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../class/abstract_Place.dart';
import '../widgets/dialogs/GenericAlertDialog.dart';

/// check if FOSSWarn has the right permissions to determine the current position
Future<bool> checkLocationPermission(BuildContext context) async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return GenericAlertDialog(
            content:
                "FOSS Warn can automatically determine the current position and"
                " additionally play current warnings for this location."
                " To do this, FOSS Warn must have access to your position. "
                "The system dialog opens immediately with the request for"
                " permission. Select 'Allow when using the app'.",
            title: "We need you permission");
      },
    );
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return GenericAlertDialog(
              title: "we need your permission",
              content:
                  "FOSSWarn doesn't have permission to access your location in the background."
                  " You cannot activate this function",
            );
          });
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, inform user
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return GenericAlertDialog(
            title: "Missing permission",
            content: ""
                "FOSS Warn does not have permissions to enable this feature."
                " If you still want to enable it, enable it in the System "
                "Preferences.",
          );
        });
    await Geolocator.openLocationSettings();
    return false;
  }

  // we can access the location while the app is in use.
  // Request the user to select always in the settings
  if (permission == LocationPermission.whileInUse) {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return GenericAlertDialog(
          title: "One more step",
          content:
              "FOSS Warn needs permission to access the location in the"
                  " background. Otherwise we will not be able to update "
                  "the current location. If you don't want this,"
                  " you can still select the locations manually.",
        );
      },
    );
    await Geolocator.openLocationSettings();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return GenericAlertDialog(
          title: "Settings changed?",
          content: "If you updated the settings, hit understand",
        );
      },
    );
  }

  permission = await Geolocator.checkPermission();

  // we still have not the right permission to operate in backgroundc^
  // inform the user, that the app can not work as expected
  if (permission != LocationPermission.always) {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return GenericAlertDialog(
            title: "Missing permission",
            content: ""
                "FOSSWarn can only access your location while you are using"
                " the app. FOSSWarn cannot update your location in the background.",
          );
        });
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
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.

      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  try {
    return await Geolocator.getCurrentPosition(
        timeLimit: Duration(seconds: 60));
  } catch (e) {
    return await Geolocator.getLastKnownPosition();
  }
}

Future<Place?> getCurrentClosedPlace() async {
  Position? currentPosition = await determinePosition();
  if (currentPosition != null) {
    try {
      return getClosedPlace(currentPosition);
    } catch (e) {
      print(
          "Error while calculating closed place base in current position: ${e.toString()}");
    }
  } else {
    print(("Could not determine position"));
  }
  // can not find current place
  return null;
}

Place getClosedPlace(Position position) {
  // print("Current position: ${position.longitude} ${position.latitude}");
  double closedDistance = -1;
  Place closedPlace =
      allAvailablePlacesNames[0]; // as temp value the first entry
  for (Place place in allAvailablePlacesNames) {
    if (place is NinaPlace) {
      double tempDistance = Geolocator.distanceBetween(
          double.parse(place.geocode.latitude.replaceAll(",", ".")),
          double.parse(place.geocode.longitude.replaceAll(",", ".")),
          position.latitude,
          position.longitude);
      if (closedDistance == -1 || tempDistance < closedDistance) {
        closedPlace = place;
        closedDistance = tempDistance;
      }
    }
  }
  print("closed Place is ${closedPlace.name}");
  // check if the closed place is in a reasonable distance
  if (closedDistance > 10000) {
    throw Exception("closed place is more then 10km away...");
  }
  return closedPlace;
}

Future<void> updateCurrentPlace([BuildContext? context]) async {
  Place? updatedPlace = await getCurrentClosedPlace();
  // only update the place if the place has changed
  if (updatedPlace != null && updatedPlace.name != userPreferences.currentPlace) {
    userPreferences.currentPlace = updatedPlace;
    // check if we have a context (when app is open) or not (when call from background)
    if (context != null) {
      print("Got place - update view");
      final updater = Provider.of<Update>(context, listen: false);
      updater.updateView();
    }
    saveSettings();
  }
}
