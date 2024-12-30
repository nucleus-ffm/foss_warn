import 'dart:math';

import 'package:flutter/material.dart';

class DouglasPeucker {
  static List<List<double>> simplify(
      List<List<double>> coordinates, double tolerance) {
    // if there are only 2 coordinates, there is nothing to do
    if (coordinates.length <= 2) {
      return coordinates;
    }

    double distanceMax = 0;
    int index = 0;
    int first = 0;
    int last = coordinates.length - 1;
    //final squareTolerance = pow(tolerance, 2);

    for (int i = 0; i < coordinates.length - 1; i++) {
      double distance = getSquareSegmentDistance(
          coordinates[i], coordinates[first], coordinates[last]);
      if (distance > distanceMax) {
        index = i;
        distanceMax = distance;
      }
    }
    debugPrint("[douglas peucker] max distance=$distanceMax");

    if (distanceMax > tolerance) {
      debugPrint(
          "[douglas peucker] max distance is greater then the tolerance $tolerance");
      List<List<double>> firstHalf =
          simplify(coordinates.sublist(0, index), tolerance);
      List<List<double>> secondHalf =
          simplify(coordinates.sublist(index, coordinates.length), tolerance);
      List<List<double>> result = [];

      result = firstHalf.sublist(0, firstHalf.length - 1) + secondHalf;
      debugPrint("[douglas peucker] $result");
      return result;
    } else {
      debugPrint("[douglas peucker] distance is smaller than the tolerance");
      List<List<double>> result = [];
      result.add(coordinates.first);
      result.add(coordinates.last);
      return result;
    }
  }

  static getSquareDistance(List<double> point1, List<double> point2) {
    final double dx = point1[0] - point2[0];
    final double dy = point2[0] - point2[0];
    return pow(dx, 2) + pow(dy, 2);
  }

  static getSquareSegmentDistance(
      List<double> p, List<double> p1, List<double> p2) {
    var x = p1.first;
    var y = p1.last;
    var dx = p2.first - x;
    var dy = p2.last - y;
    if (dx != 0 || dy != 0) {
      final t = ((p.first - x) * dx + (p.last - y) * dy) / (dx * dx + dy * dy);
      if (t > 1) {
        x = p2.first;
        y = p2.last;
      } else if (t > 0) {
        x += dx * t;
        y += dy * t;
      }
    }
    dx = p.first - x;
    dy = p.last - y;
    return dx * dx + dy * dy;
  }
}
