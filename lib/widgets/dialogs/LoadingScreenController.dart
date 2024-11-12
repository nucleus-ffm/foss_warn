import 'package:flutter/foundation.dart' show immutable;

typedef CloseLoadingScreen = bool Function();
typedef UpdateLoadingScreen = bool Function(String text);

@immutable
class LoadingScreenController {
  final CloseLoadingScreen close; // to close our dialog
  final UpdateLoadingScreen update; // to update any text with in our dialog if needed

  const LoadingScreenController({
    required this.close,
    required this.update,
  });
}