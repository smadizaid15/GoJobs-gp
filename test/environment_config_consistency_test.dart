import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gp1_mvp/config/app_environment.dart';

// Structural "one environment identity" check (Phase 1B):
//
//   native flavor -> applicationId -> google-services.json / plist
//     -> appFlavor -> Dart FirebaseOptions -> Firebase project
//
// should all agree. app_environment_test.dart already covers the Dart-only
// half (AppEnvironmentConfig.projectIdFor / optionsFor). This file closes
// the other half: it reads the actual committed native config files for
// each environment and asserts their project id matches
// AppEnvironmentConfig.projectIdFor(...) directly — catching drift if
// someone regenerates a google-services.json/plist for the wrong project,
// independent of any runtime check on a real build.
void main() {
  const flavors = {
    AppEnvironment.dev: 'dev',
    AppEnvironment.staging: 'staging',
    AppEnvironment.prod: 'prod',
  };

  group(
    'android/app/src/<flavor>/google-services.json matches AppEnvironmentConfig',
    () {
      for (final entry in flavors.entries) {
        final env = entry.key;
        final flavor = entry.value;
        test(
          '$flavor flavor config points at ${AppEnvironmentConfig.projectIdFor(env)}',
          () {
            final file = File('android/app/src/$flavor/google-services.json');
            expect(
              file.existsSync(),
              isTrue,
              reason: '${file.path} must exist',
            );
            final json =
                jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
            final projectInfo = json['project_info'] as Map<String, dynamic>;
            expect(
              projectInfo['project_id'],
              AppEnvironmentConfig.projectIdFor(env),
            );
          },
        );
      }
    },
  );

  group(
    'ios/Runner/Firebase/<env>/GoogleService-Info.plist matches AppEnvironmentConfig',
    () {
      for (final entry in flavors.entries) {
        final env = entry.key;
        final flavor = entry.value;
        test(
          '$flavor plist points at ${AppEnvironmentConfig.projectIdFor(env)}',
          () {
            final file = File(
              'ios/Runner/Firebase/$flavor/GoogleService-Info.plist',
            );
            expect(
              file.existsSync(),
              isTrue,
              reason: '${file.path} must exist',
            );
            final content = file.readAsStringSync();
            final match = RegExp(
              r'<key>PROJECT_ID</key>\s*<string>([^<]+)</string>',
            ).firstMatch(content);
            expect(
              match,
              isNotNull,
              reason: 'PROJECT_ID key not found in ${file.path}',
            );
            expect(match!.group(1), AppEnvironmentConfig.projectIdFor(env));
          },
        );
      }
    },
  );
}
