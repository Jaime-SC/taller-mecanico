// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows; // Devuelve la configuración para Windows.
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
    apiKey: 'AIzaSyBbJTlqrpuMhKq1Godw1eD6c6_rgclWluM',
    appId: '1:590908195503:web:a9263a6989b9bd46da4a5a',
    messagingSenderId: '590908195503',
    projectId: 'tallermecanico-97e5f',
    authDomain: 'tallermecanico-97e5f.firebaseapp.com',
    storageBucket: 'tallermecanico-97e5f.appspot.com',
    measurementId: 'G-M7TZ33F6H4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAB9WPPeJ4WTYGnAebbr5yXl3Ol9iYSd5o',
    appId: '1:590908195503:android:5f1517eedfcabb4bda4a5a',
    messagingSenderId: '590908195503',
    projectId: 'tallermecanico-97e5f',
    storageBucket: 'tallermecanico-97e5f.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBbJTlqrpuMhKq1Godw1eD6c6_rgclWluM',
    appId: '1:590908195503:web:bfd20bab90ce678eda4a5a',
    messagingSenderId: '590908195503',
    projectId: 'tallermecanico-97e5f',
    authDomain: 'tallermecanico-97e5f.firebaseapp.com',
    storageBucket: 'tallermecanico-97e5f.appspot.com',
    measurementId: 'G-KPT67MMZBJ',
  );
}
