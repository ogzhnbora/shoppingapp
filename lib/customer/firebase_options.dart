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
    apiKey: 'AIzaSyBLesRFoAW0Mt7btRTWXLg3mn6YXT0e5aU',
    appId: '1:174262950931:web:3b2d456f4cf513f99333e6',
    messagingSenderId: '174262950931',
    projectId: 'shopping-app-22098',
    authDomain: 'shopping-app-22098.firebaseapp.com',
    storageBucket: 'shopping-app-22098.appspot.com',
    measurementId: 'G-YFC1WSZFCC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDiTcVhsEMCrIoD7mQGXYZ8sh-qzcW-wwI',
    appId: '1:174262950931:android:2c96ec2fb43ef4409333e6',
    messagingSenderId: '174262950931',
    projectId: 'shopping-app-22098',
    storageBucket: 'shopping-app-22098.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_2v0tPcpwcbU5vdzFSTGHLgHHA1mwQjE',
    appId: '1:174262950931:ios:feb8ce43445bb3919333e6',
    messagingSenderId: '174262950931',
    projectId: 'shopping-app-22098',
    storageBucket: 'shopping-app-22098.appspot.com',
    iosBundleId: 'com.example.finalproject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB_2v0tPcpwcbU5vdzFSTGHLgHHA1mwQjE',
    appId: '1:174262950931:ios:feb8ce43445bb3919333e6',
    messagingSenderId: '174262950931',
    projectId: 'shopping-app-22098',
    storageBucket: 'shopping-app-22098.appspot.com',
    iosBundleId: 'com.example.finalproject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBLesRFoAW0Mt7btRTWXLg3mn6YXT0e5aU',
    appId: '1:174262950931:web:f8b4783d0d2f2c629333e6',
    messagingSenderId: '174262950931',
    projectId: 'shopping-app-22098',
    authDomain: 'shopping-app-22098.firebaseapp.com',
    storageBucket: 'shopping-app-22098.appspot.com',
    measurementId: 'G-VHE7QBSWJ6',
  );
}