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
    apiKey: 'AIzaSyAyOMkFcuUt4u06JZyeFjTTo66mVkocxEw',
    appId: '1:296950472410:web:486825c6868cb7c60c4fe3',
    messagingSenderId: '296950472410',
    projectId: 'phone-firebase-e0105',
    authDomain: 'phone-firebase-e0105.firebaseapp.com',
    storageBucket: 'phone-firebase-e0105.appspot.com',
    measurementId: 'G-QGEL94YF83',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAyGJL-1sD_-OgiIOHmbpGelqG77AsRTpc',
    appId: '1:296950472410:android:4a16da219fb9807c0c4fe3',
    messagingSenderId: '296950472410',
    projectId: 'phone-firebase-e0105',
    storageBucket: 'phone-firebase-e0105.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAodl_jtudA0Qbo8BSEaD7LZ1x9y-c0WMI',
    appId: '1:296950472410:ios:8d25ed5013b45ca60c4fe3',
    messagingSenderId: '296950472410',
    projectId: 'phone-firebase-e0105',
    storageBucket: 'phone-firebase-e0105.appspot.com',
    iosBundleId: 'com.example.loka',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAodl_jtudA0Qbo8BSEaD7LZ1x9y-c0WMI',
    appId: '1:296950472410:ios:8d25ed5013b45ca60c4fe3',
    messagingSenderId: '296950472410',
    projectId: 'phone-firebase-e0105',
    storageBucket: 'phone-firebase-e0105.appspot.com',
    iosBundleId: 'com.example.loka',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAyOMkFcuUt4u06JZyeFjTTo66mVkocxEw',
    appId: '1:296950472410:web:7bb510dd379f3a8c0c4fe3',
    messagingSenderId: '296950472410',
    projectId: 'phone-firebase-e0105',
    authDomain: 'phone-firebase-e0105.firebaseapp.com',
    storageBucket: 'phone-firebase-e0105.appspot.com',
    measurementId: 'G-TEMS3W0RKX',
  );
}
