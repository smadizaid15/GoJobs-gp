import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase options for the `gojobs-dev` project, generated from the
/// registered Firebase apps (`firebase apps:sdkconfig`, 2026-09-11) — not
/// hand-invented, and never a copy of production's values. Only Android
/// and iOS apps are registered for this project so far; other platforms
/// throw clearly rather than silently falling back to any other project.
class DefaultFirebaseOptionsDev {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'No web Firebase app is registered for gojobs-dev yet.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptionsDev only supports Android and iOS today.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBDxn9O13oKGId7rN46n7teLMi2G-aVC3M',
    appId: '1:17773055683:android:f651c0657b9f0838b9dc76',
    messagingSenderId: '17773055683',
    projectId: 'gojobs-dev',
    storageBucket: 'gojobs-dev.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD6Sl-1uI4O_bUbnnUNfNOlGCdUgmKgrT4',
    appId: '1:17773055683:ios:c18a48ba5a7f074eb9dc76',
    messagingSenderId: '17773055683',
    projectId: 'gojobs-dev',
    storageBucket: 'gojobs-dev.firebasestorage.app',
    iosBundleId: 'com.gojobs.app.dev',
  );
}
