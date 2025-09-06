class DouglasPeucker {
  /// simplify a given list of coordinates with the douglas-peucker algorithm.
  /// Here, we assume that the input is a polygon. So, the last coordinate
  /// is also the first coordinate. The result also consists of
  /// at least four coordinates to form a polygon.
  static List<List<double>> simplify({
    required List<List<double>> coordinates,
    required double tolerance,
  }) {
    // if there are only 4 coordinates, there is nothing to do
    // we need at least 4 coordinates to display a polygon
    if (coordinates.length <= 5) {
      return coordinates;
    }

    List<int> stack = [0, coordinates.length - 1];
    List<bool> keep = List<bool>.filled(coordinates.length, false);

    // to ensure that we always have at least 4 coordinates we set 4 coordinates
    // to true. Here we just approximate the four coordinates based on the length
    // of the coordinates array. We could surely find a cleaner solution.
    keep[0] = true;
    int stepSize = coordinates.length ~/ 4;
    keep[stepSize] = true;
    keep[stepSize * 2] = true;
    keep[stepSize * 3] = true;
    keep[coordinates.length - 1] = true;

    while (stack.isNotEmpty) {
      final last = stack.removeLast();
      final first = stack.removeLast();

      double maxDistance = 0;
      int index = 0;

      for (int i = first + 1; i < last; i++) {
        final distance = getSquareSegmentDistance(
          coordinates[i],
          coordinates[first],
          coordinates[last],
        );
        if (distance > maxDistance) {
          maxDistance = distance;
          index = i;
        }
      }

      if (maxDistance > tolerance) {
        keep[index] = true;
        stack.add(first);
        stack.add(index);
        stack.add(index);
        stack.add(last);
      }
    }

    List<List<double>> result = [];
    for (int i = 0; i < coordinates.length; i++) {
      if (keep[i]) {
        result.add(
          coordinates[i],
        );
      }
    }

    return result;
  }

  static double getSquareSegmentDistance(
    List<double> p,
    List<double> p1,
    List<double> p2,
  ) {
    var x = p1[0];
    var y = p1[1];
    var dx = p2[0] - x;
    var dy = p2[1] - y;

    if (dx != 0 || dy != 0) {
      final t = ((p[0] - x) * dx + (p[1] - y) * dy) / (dx * dx + dy * dy);
      if (t > 1) {
        x = p2[0];
        y = p2[1];
      } else if (t > 0) {
        x += dx * t;
        y += dy * t;
      }
    }

    dx = p[0] - x;
    dy = p[1] - y;

    return dx * dx + dy * dy;
  }
}
