import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/services/legacy_handler.dart';
import 'package:foss_warn/services/server.dart';

import 'class/class_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPreferencesState.initialize();
  await legacyHandler();
  //startWebserver();

  var showWelcomeScreen =
      SharedPreferencesState.instance.getBool("showWelcomeScreen") ?? true;

  if (!showWelcomeScreen) {
    // do not ask for notification permission before the user finished the
    // welcome dialog
    await NotificationService().init();
  }

  runApp(
    const ProviderScope(child: FOSSWarn()),
  );
}

class FOSSWarn extends ConsumerWidget {
  const FOSSWarn({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var routes = ref.read(routesProvider);

    var themeMode = ref.watch(
      userPreferencesProvider
          .select((preferences) => preferences.selectedThemeMode),
    );
    var selectedLightTheme = ref.watch(
      userPreferencesProvider
          .select((preferences) => preferences.selectedLightTheme),
    );
    var selectedDarkTheme = ref.watch(
      userPreferencesProvider
          .select((preferences) => preferences.selectedDarkTheme),
    );

    return MaterialApp.router(
      title: 'FOSS Warn',
      theme: selectedLightTheme,
      darkTheme: selectedDarkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: routes,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
