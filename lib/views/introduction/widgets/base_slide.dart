import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';

class IntroductionBaseSlide extends ConsumerWidget {
  const IntroductionBaseSlide({
    required this.imagePath,
    required this.title,
    required this.text,
    this.footer,
    super.key,
  });

  final String imagePath;
  final String title;
  final String text;
  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var userPreferences = ref.watch(userPreferencesProvider);

    final brightness = userPreferences.selectedThemeMode;
    final darkModeOn = brightness == ThemeMode.dark;
    const String basePath = "assets/introduction";
    final String themeDependedPath =
        darkModeOn ? "$basePath/darkmode" : "$basePath/lightmode";

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0).copyWith(top: 120.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "$themeDependedPath/$imagePath",
              fit: BoxFit.contain,
              width: 220.0,
              height: 200.0,
              alignment: Alignment.bottomCenter,
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 29.0,
                fontWeight: FontWeight.w300,
                height: 2.0,
              ),
            ),
            Text(
              text,
              style: const TextStyle(
                color: Colors.grey,
                letterSpacing: 1.2,
                fontSize: 16.0,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            if (footer != null) ...[
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
