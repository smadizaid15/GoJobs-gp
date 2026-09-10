import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gp1_mvp/providers/theme_provider.dart';

// This file replaces the original `widget_test.dart` template smoke test,
// which pumped `GoJobsApp` directly. That test became obsolete the moment
// `main.dart` was rewritten to require a `MultiProvider([ThemeProvider,
// AuthProvider])` ancestor (commit 3934493) without the test being updated
// to match — see docs/ROADMAP.md's Phase 1 preflight notes for the full
// history. Wrapping the pumped widget in the same MultiProvider fixes the
// original ProviderNotFoundException, but exposes a second, deeper problem:
// SplashScreen (the initial route) reads AuthProvider after a 2-second
// Future.delayed, and AuthProvider's constructor eagerly touches
// FirebaseAuth.instance. Advancing the fake test clock past that delay
// (confirmed empirically) throws FirebaseException([core/no-app]), because
// `flutter test` never calls Firebase.initializeApp() and has no emulator
// to talk to. Pumping the full app is therefore inherently non-hermetic.
//
// ThemeProvider is the one piece of the app's provider layer with no
// Firebase dependency, so it is exercised directly here instead, as a real
// regression test of production logic rather than a assertion-free smoke
// test.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults to light mode when no preference is stored', () async {
    SharedPreferences.setMockInitialValues({});
    final themeProvider = ThemeProvider();
    await Future<void>.delayed(Duration.zero);

    expect(themeProvider.themeMode, ThemeMode.light);
    expect(themeProvider.isDarkMode, isFalse);
  });

  test('loads a previously stored dark-mode preference', () async {
    SharedPreferences.setMockInitialValues({'isDarkMode': true});
    final themeProvider = ThemeProvider();
    await Future<void>.delayed(Duration.zero);

    expect(themeProvider.themeMode, ThemeMode.dark);
    expect(themeProvider.isDarkMode, isTrue);
  });

  test(
    'toggleTheme updates state, notifies listeners, and persists the choice',
    () async {
      SharedPreferences.setMockInitialValues({});
      final themeProvider = ThemeProvider();
      await Future<void>.delayed(Duration.zero);

      var notified = false;
      themeProvider.addListener(() => notified = true);

      themeProvider.toggleTheme(true);

      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(themeProvider.isDarkMode, isTrue);
      expect(notified, isTrue);

      await Future<void>.delayed(Duration.zero);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isDarkMode'), isTrue);
    },
  );
}
