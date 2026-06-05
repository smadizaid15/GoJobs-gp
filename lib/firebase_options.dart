import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBrj0oEYuO4CYduxs3A4W75zo_b00jYdFE',
    appId: '1:944928167403:web:4a4a16f34100b09ccc75ae',
    messagingSenderId: '944928167403',
    projectId: 'gojobs-187af',
    authDomain: 'gojobs-187af.firebaseapp.com',
    storageBucket: 'gojobs-187af.firebasestorage.app',
    measurementId: 'G-SGQQ1LR8NX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAbUHbXrJUCWFPknagffYhPiiKXHQ86u6I',
    appId: '1:944928167403:android:445fcf1e636646e9cc75ae',
    messagingSenderId: '944928167403',
    projectId: 'gojobs-187af',
    storageBucket: 'gojobs-187af.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBIxj2KhDkcHVHHo--Lvz0yoNBIgjXPiKg',
    appId: '1:944928167403:ios:4b8b07488de5297dcc75ae',
    messagingSenderId: '944928167403',
    projectId: 'gojobs-187af',
    storageBucket: 'gojobs-187af.firebasestorage.app',
    iosBundleId: 'com.example.gp1Mvp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBIxj2KhDkcHVHHo--Lvz0yoNBIgjXPiKg',
    appId: '1:944928167403:ios:4b8b07488de5297dcc75ae',
    messagingSenderId: '944928167403',
    projectId: 'gojobs-187af',
    storageBucket: 'gojobs-187af.firebasestorage.app',
    iosBundleId: 'com.example.gp1Mvp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBrj0oEYuO4CYduxs3A4W75zo_b00jYdFE',
    appId: '1:944928167403:web:37809fe2764ad867cc75ae',
    messagingSenderId: '944928167403',
    projectId: 'gojobs-187af',
    authDomain: 'gojobs-187af.firebaseapp.com',
    storageBucket: 'gojobs-187af.firebasestorage.app',
    measurementId: 'G-DYQCH7SFF0',
  );
}