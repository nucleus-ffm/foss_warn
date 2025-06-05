extension ListFilterWithNull<T> on List<T> {
  /// return the first element for which the test was successful,
  /// or return null if no element matches the test
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
