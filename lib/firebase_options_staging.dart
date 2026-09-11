import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase options for the `gojobs-staging` project, generated from the
/// registered Firebase apps (`firebase apps:sdkconfig`, 2026-09-11) — not
/// hand-invented, and never a copy of production's values. Only Android
/// and iOS apps are registered for this project so far; other platforms
/// throw clearly rather than silently falling back to any other project.
class DefaultFirebaseOptionsStaging {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'No web Firebase app is registered for gojobs-staging yet.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptionsStaging only supports Android and iOS today.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBs1T-BkMdVjOJYcyFgCIuqrNNM2qNdnUs',
    appId: '1:1047239227213:android:8d09899232529d9fd52904',
    messagingSenderId: '1047239227213',
    projectId: 'gojobs-staging',
    storageBucket: 'gojobs-staging.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYFnaouK2GVTG4O_E_wAWIXvRf4ibjnk0',
    appId: '1:1047239227213:ios:bedf88d175dbaa42d52904',
    messagingSenderId: '1047239227213',
    projectId: 'gojobs-staging',
    storageBucket: 'gojobs-staging.firebasestorage.app',
    iosBundleId: 'com.gojobs.app.staging',
  );
}
