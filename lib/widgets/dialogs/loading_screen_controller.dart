import 'package:flutter/foundation.dart' show immutable;

typedef CloseLoadingScreen = bool Function();
typedef UpdateLoadingScreen = bool Function(String text);
typedef ResultLoadingScreen = bool Function(String text);

@immutable
class LoadingScreenController {
  /// To close the dialog
  final CloseLoadingScreen close;

  /// To update the text with in the dialog if needed
  final UpdateLoadingScreen update;

  /// To display the result message of the loading process
  /// This also shows a close button to hide the overlay, so this can be
  /// called instead of hiding the overlay manually
  final ResultLoadingScreen result;

  const LoadingScreenController({
    required this.close,
    required this.update,
    required this.result,
  });
}
