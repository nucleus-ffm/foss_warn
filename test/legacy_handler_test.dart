import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/services/legacy_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// The build number the "installed" app reports during these tests.
const String currentBuildNumber = "44";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    PackageInfo.setMockInitialValues(
      appName: "FOSS Warn",
      packageName: "de.nucleus.foss_warn",
      version: "1.1.0",
      buildNumber: currentBuildNumber,
      buildSignature: "",
    );
    await SharedPreferencesState.initialize();
  });

  setUp(() async {
    await SharedPreferencesState.instance.clear();
  });

  test('a fresh install only records the current version', () async {
    await legacyHandler();

    final preferences = SharedPreferencesState.instance;
    expect(preferences.getInt("previousInstalledVersionCode"), 44);
    expect(preferences.getBool("showUpdateDialog"), isNull);
  });

  test('an upgrade across several versions runs every migration', () async {
    // Regression test: the migrations used to be chained with `else if`, so an
    // upgrade from 40 straight to 45 skipped the server url migration and left
    // the app with an unusable "https://..." authority.
    final preferences = SharedPreferencesState.instance;
    await preferences.setInt("previousInstalledVersionCode", 40);
    await preferences.setString(
      "fossPublicAlertServerUrl",
      "https://alerts.example.org",
    );

    await legacyHandler();

    expect(preferences.getBool("showUpdateDialog"), isTrue);
    expect(
      preferences.getString("fossPublicAlertServerUrl"),
      "alerts.example.org",
    );
    expect(preferences.getInt("previousInstalledVersionCode"), 44);
  });

  test('the url migration also strips a plain http scheme', () async {
    final preferences = SharedPreferencesState.instance;
    await preferences.setInt("previousInstalledVersionCode", 43);
    await preferences.setString(
      "fossPublicAlertServerUrl",
      "http://alerts.example.org",
    );

    await legacyHandler();

    expect(
      preferences.getString("fossPublicAlertServerUrl"),
      "alerts.example.org",
    );
  });

  test('a url without a scheme is left alone', () async {
    final preferences = SharedPreferencesState.instance;
    await preferences.setInt("previousInstalledVersionCode", 43);
    await preferences.setString("fossPublicAlertServerUrl", "alerts.kde.org");

    await legacyHandler();

    expect(preferences.getString("fossPublicAlertServerUrl"), "alerts.kde.org");
  });

  test('the retired areWarningsFromCache flag is removed', () async {
    final preferences = SharedPreferencesState.instance;
    await preferences.setInt("previousInstalledVersionCode", 43);
    await preferences.setBool("areWarningsFromCache", true);

    await legacyHandler();

    expect(preferences.getBool("areWarningsFromCache"), isNull);
  });

  test('an upgrade from a pre 8.x version resets the settings', () async {
    final preferences = SharedPreferencesState.instance;
    await preferences.setInt("previousInstalledVersionCode", 33);
    await preferences.setString("MyPlacesListAsJson", "[]");
    await preferences.setBool("showWelcomeScreen", false);

    await legacyHandler();

    expect(preferences.getString("MyPlacesListAsJson"), isNull);
    expect(preferences.getBool("showWelcomeScreen"), isNull);
    expect(preferences.getInt("previousInstalledVersionCode"), 44);
  });

  test('reopening the same version migrates nothing', () async {
    final preferences = SharedPreferencesState.instance;
    await preferences.setInt("previousInstalledVersionCode", 44);
    await preferences.setString(
      "fossPublicAlertServerUrl",
      "https://alerts.example.org",
    );

    await legacyHandler();

    expect(preferences.getBool("showUpdateDialog"), isNull);
    expect(
      preferences.getString("fossPublicAlertServerUrl"),
      "https://alerts.example.org",
      reason: "no migration may run when the version did not change",
    );
  });
}
