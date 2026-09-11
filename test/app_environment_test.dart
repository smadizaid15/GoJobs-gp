import 'package:flutter_test/flutter_test.dart';
import 'package:gp1_mvp/config/app_environment.dart';

// Production-isolation checks for Phase 1B (environment isolation). These
// exercise the parsing/mapping logic directly with literal strings rather
// than via AppEnvironmentConfig.current, because Flutter's `appFlavor` —
// like `String.fromEnvironment` — is a compile-time constant fixed for the
// whole test binary; a single `flutter test` run can't otherwise observe
// more than one flavor's behavior.
void main() {
  group('AppEnvironmentConfig.parseFlavor', () {
    test('accepts exactly "dev", "staging", "prod"', () {
      expect(AppEnvironmentConfig.parseFlavor('dev'), AppEnvironment.dev);
      expect(
        AppEnvironmentConfig.parseFlavor('staging'),
        AppEnvironment.staging,
      );
      expect(AppEnvironmentConfig.parseFlavor('prod'), AppEnvironment.prod);
    });

    test('throws — never defaults to prod — when no --flavor was given', () {
      // null is exactly what Flutter's appFlavor resolves to when
      // --flavor was never passed — the single most important case to
      // get right, since it's what a bare `flutter run`/`flutter build`
      // would produce.
      expect(() => AppEnvironmentConfig.parseFlavor(null), throwsStateError);
    });

    test('throws on an unrecognized flavor instead of guessing', () {
      for (final bad in [
        'production',
        'Prod',
        'PROD',
        'development',
        'stage',
        'gojobs-187af',
        ' prod',
        'prod ',
        '',
      ]) {
        expect(
          () => AppEnvironmentConfig.parseFlavor(bad),
          throwsStateError,
          reason: '"$bad" must not be silently accepted',
        );
      }
    });
  });

  group('AppEnvironmentConfig.projectIdFor — production isolation', () {
    test('dev resolves only to gojobs-dev', () {
      expect(
        AppEnvironmentConfig.projectIdFor(AppEnvironment.dev),
        'gojobs-dev',
      );
    });

    test('staging resolves only to gojobs-staging', () {
      expect(
        AppEnvironmentConfig.projectIdFor(AppEnvironment.staging),
        'gojobs-staging',
      );
    });

    test('prod resolves only to gojobs-187af', () {
      expect(
        AppEnvironmentConfig.projectIdFor(AppEnvironment.prod),
        'gojobs-187af',
      );
    });

    test('every environment maps to a distinct project id', () {
      final ids = AppEnvironment.values
          .map(AppEnvironmentConfig.projectIdFor)
          .toSet();
      expect(ids.length, AppEnvironment.values.length);
    });
  });

  group(
    'AppEnvironmentConfig.optionsFor — real, distinct, isolated configuration',
    () {
      test('prod returns real options pointing at gojobs-187af', () {
        final options = AppEnvironmentConfig.optionsFor(AppEnvironment.prod);
        expect(options.projectId, 'gojobs-187af');
      });

      test('dev returns real options pointing at gojobs-dev', () {
        final options = AppEnvironmentConfig.optionsFor(AppEnvironment.dev);
        expect(options.projectId, 'gojobs-dev');
      });

      test('staging returns real options pointing at gojobs-staging', () {
        final options = AppEnvironmentConfig.optionsFor(AppEnvironment.staging);
        expect(options.projectId, 'gojobs-staging');
      });

      test('no environment ever returns another environment\'s project', () {
        // The critical guarantee: there is no code path by which a dev or
        // staging build could end up holding production's FirebaseOptions
        // (or each other's).
        final byEnv = {
          for (final env in AppEnvironment.values)
            env: AppEnvironmentConfig.optionsFor(env).projectId,
        };
        expect(byEnv.values.toSet().length, AppEnvironment.values.length);
        expect(byEnv[AppEnvironment.prod], 'gojobs-187af');
        expect(byEnv[AppEnvironment.dev], isNot('gojobs-187af'));
        expect(byEnv[AppEnvironment.staging], isNot('gojobs-187af'));
      });
    },
  );
}
