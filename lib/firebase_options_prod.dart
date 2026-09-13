import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase options for the `gojobs-187af` (production) project, under the
/// newly-approved `com.gojobs.app` identifier — generated from the
/// registered Firebase apps (`firebase apps:sdkconfig`, 2026-09-11).
///
/// The legacy `lib/firebase_options.dart` (Android/iOS entries registered
/// against the old `com.example.gp1_mvp` / `com.example.gp1Mvp` identifiers,
/// plus unused macOS/windows/web members) was removed 2026-09-11 as part of
/// the Phase 1B environment-isolation hygiene pass — nothing in the
/// environment-aware code path ever imported it, and keeping an unused,
/// production-capable Firebase config around was itself a risk. The legacy
/// Firebase app registrations it pointed at still exist in `gojobs-187af`
/// (not renamed/deleted), so recovering those values from the Firebase
/// Console or `firebase apps:sdkconfig` is still possible if ever needed.
class DefaultFirebaseOptionsProd {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Web is not environment-isolated today (see docs/architecture/
      // ENVIRONMENTS.md — "Web platform status") and is treated as
      // unsupported/deferred, not wired into any per-environment options
      // class. A prod-environment web build needs a new, from-scratch
      // per-environment web design, not a copy of the removed legacy file.
      throw UnsupportedError(
        'Web is not wired into DefaultFirebaseOptionsProd — web is '
        'unsupported/deferred pending a real per-environment design (see '
        'docs/architecture/ENVIRONMENTS.md).',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptionsProd only supports Android and iOS today.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAbUHbXrJUCWFPknagffYhPiiKXHQ86u6I',
    appId: '1:944928167403:android:e4c953e9b51fcab7cc75ae',
    messagingSenderId: '944928167403',
    projectId: 'gojobs-187af',
    storageBucket: 'gojobs-187af.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBIxj2KhDkcHVHHo--Lvz0yoNBIgjXPiKg',
    appId: '1:944928167403:ios:e63c4cad648ccecccc75ae',
    messagingSenderId: '944928167403',
    projectId: 'gojobs-187af',
    storageBucket: 'gojobs-187af.firebasestorage.app',
    iosBundleId: 'com.gojobs.app',
  );
}
