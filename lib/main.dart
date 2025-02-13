import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/services/legacy_handler.dart';
import 'package:foss_warn/views/introduction/introduction_view.dart';
import 'package:foss_warn/views/home/home_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'class/class_app_state.dart';
import 'class/class_notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final AppState appState = AppState();
final UserPreferences userPreferences = UserPreferences();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await legacyHandler();
  await userPreferences.init();
  if (!userPreferences.showWelcomeScreen) {
    // do not ask for notification permission before the user finished the
    // welcome dialog
    await NotificationService().init();
  }

  runApp(const FOSSWarn());
}

class FOSSWarn extends StatelessWidget {
  const FOSSWarn({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'FOSS Warn',
        theme: userPreferences.selectedLightTheme,
        darkTheme: userPreferences.selectedDarkTheme,
        themeMode: userPreferences.selectedThemeMode,
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: userPreferences.showWelcomeScreen
            ? const IntroductionView()
            : const HomeView(),
      ),
    );
  }
}
