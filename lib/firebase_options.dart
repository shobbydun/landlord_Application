// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyCOw1lO3AUc1gHJcyFmi5QadYrhd7HhrVE',
    appId: '1:258730011220:web:76178527297086c3381bc1',
    messagingSenderId: '258730011220',
    projectId: 'landify-ca8bb',
    authDomain: 'landify-ca8bb.firebaseapp.com',
    storageBucket: 'landify-ca8bb.firebasestorage.app',
    measurementId: 'G-NR5C2TXVZM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCUJR0LrhXwSo1q7QOitGr52c7JxN_mDdc',
    appId: '1:258730011220:android:4ad9e1af8fa0c38f381bc1',
    messagingSenderId: '258730011220',
    projectId: 'landify-ca8bb',
    storageBucket: 'landify-ca8bb.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyACsMgpfx7cxoGr7ktS2AyD1cSnROGcY5s',
    appId: '1:258730011220:ios:e6fa29f70d2fad9c381bc1',
    messagingSenderId: '258730011220',
    projectId: 'landify-ca8bb',
    storageBucket: 'landify-ca8bb.firebasestorage.app',
    iosBundleId: 'com.example.landify',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyACsMgpfx7cxoGr7ktS2AyD1cSnROGcY5s',
    appId: '1:258730011220:ios:e6fa29f70d2fad9c381bc1',
    messagingSenderId: '258730011220',
    projectId: 'landify-ca8bb',
    storageBucket: 'landify-ca8bb.firebasestorage.app',
    iosBundleId: 'com.example.landify',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCOw1lO3AUc1gHJcyFmi5QadYrhd7HhrVE',
    appId: '1:258730011220:web:4a88b472b158febb381bc1',
    messagingSenderId: '258730011220',
    projectId: 'landify-ca8bb',
    authDomain: 'landify-ca8bb.firebaseapp.com',
    storageBucket: 'landify-ca8bb.firebasestorage.app',
    measurementId: 'G-RMNVCC8D7T',
  );
}
