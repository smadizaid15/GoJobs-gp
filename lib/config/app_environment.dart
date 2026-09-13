import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/services.dart' show appFlavor;

import '../firebase_options_dev.dart' show DefaultFirebaseOptionsDev;
import '../firebase_options_prod.dart' show DefaultFirebaseOptionsProd;
import '../firebase_options_staging.dart' show DefaultFirebaseOptionsStaging;

/// The three isolated Firebase/GCP environments this app can run against.
/// See docs/architecture/ENVIRONMENTS.md for the full environment strategy.
enum AppEnvironment { dev, staging, prod }

/// Single source of truth for "which environment is this build, and which
/// Firebase project does it talk to." Every other part of the app should
/// go through this class rather than branching on environment directly.
///
/// The native Android product flavor / iOS scheme (`--flavor dev` etc.) is
/// the *sole* environment selector — there is deliberately no second,
/// independently-settable value (a `--dart-define=ENVIRONMENT=...` used to
/// exist alongside `--flavor` and required a runtime cross-check to catch
/// the two disagreeing; removed, because Flutter's own `appFlavor`
/// (`package:flutter/services.dart`, backed by `FLUTTER_APP_FLAVOR`) is
/// set directly by the `--flavor` flag itself — there is no second lever
/// left for a developer to mismatch).
///
/// The parsing logic is exposed as a plain static function taking the raw
/// flavor string (rather than reading `appFlavor` directly inside a
/// getter) so it can be exercised in `flutter test` with literal values —
/// `appFlavor`, like `String.fromEnvironment`, is a compile-time constant
/// fixed for the whole test binary, so a single test run can't otherwise
/// observe more than one flavor's behavior.
class AppEnvironmentConfig {
  const AppEnvironmentConfig._();

  /// Parses the native `--flavor` value (Flutter's `appFlavor`) into an
  /// [AppEnvironment].
  ///
  /// There is deliberately no default case that falls back to production,
  /// and no case for a missing flavor. A bare `flutter run`/`flutter
  /// build` with no `--flavor` produces `appFlavor == null`, which must
  /// fail loudly here — not silently launch against production.
  static AppEnvironment parseFlavor(String? flavor) {
    switch (flavor) {
      case 'dev':
        return AppEnvironment.dev;
      case 'staging':
        return AppEnvironment.staging;
      case 'prod':
        return AppEnvironment.prod;
      default:
        throw StateError(
          'No valid --flavor was provided at build time (got: '
          '${flavor == null ? 'none' : '"$flavor"'}). Every build must '
          'explicitly pass --flavor dev, --flavor staging, or --flavor '
          'prod. Refusing to guess or fall back to production.',
        );
    }
  }

  /// The environment this build was compiled for, resolved once from the
  /// native `--flavor` (Flutter's `appFlavor`).
  static AppEnvironment get current => parseFlavor(appFlavor);

  /// The Firebase project ID a given [AppEnvironment] resolves to. This is
  /// the core production-isolation guarantee: dev can only ever name
  /// `gojobs-dev`, staging only `gojobs-staging`, prod only `gojobs-187af`
  /// — there is no path through this function that lets one environment's
  /// value be mistaken for another's.
  static String projectIdFor(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.dev:
        return 'gojobs-dev';
      case AppEnvironment.staging:
        return 'gojobs-staging';
      case AppEnvironment.prod:
        return 'gojobs-187af';
    }
  }

  /// The Firebase project ID for [current].
  static String get firebaseProjectId => projectIdFor(current);

  /// The [FirebaseOptions] for a given [AppEnvironment], generated from the
  /// actual registered Firebase app in that project (`firebase
  /// apps:sdkconfig`, 2026-09-11) — never copied from another environment.
  static FirebaseOptions optionsFor(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.dev:
        return DefaultFirebaseOptionsDev.currentPlatform;
      case AppEnvironment.staging:
        return DefaultFirebaseOptionsStaging.currentPlatform;
      case AppEnvironment.prod:
        return DefaultFirebaseOptionsProd.currentPlatform;
    }
  }

  /// The [FirebaseOptions] for [current].
  static FirebaseOptions get firebaseOptions => optionsFor(current);

  /// Short label for logs/UI badges — not used for any security decision.
  static String get name => current.name;
}
