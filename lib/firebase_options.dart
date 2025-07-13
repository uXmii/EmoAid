// lib/firebase_options.dart - COMPLETE WITH YOUR REAL FIREBASE KEYS
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  // ✅ ANDROID CONFIGURATION - YOUR ACTUAL VALUES
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBPkMdGFm30eWKi5cBS4asc4IN81nrbzWc',
    appId: '1:573188538666:android:36011cf9c3adfc0edede53',  // ✅ Your real Android App ID
    messagingSenderId: '573188538666',
    projectId: 'emoaid-fc5ce',
    storageBucket: 'emoaid-fc5ce.appspot.com',
  );

  // iOS CONFIGURATION - You can add these later when you create iOS app
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBPkMdGFm30eWKi5cBS4asc4IN81nrbzWc',  // Usually different for iOS
    appId: '1:573188538666:android:36011cf9c3adfc0edede53',  // You'll get this when adding iOS app
    messagingSenderId: '573188538666',
    projectId: 'emoaid-fc5ce',
    storageBucket: 'emoaid-fc5ce.appspot.com',
    iosClientId: 'your-ios-client-id.googleusercontent.com',  // You'll get this when adding iOS app
    iosBundleId: 'com.bluethread.emoaid',
  );

  // ✅ WEB CONFIGURATION - YOUR ACTUAL VALUES
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBPkMdGFm30eWKi5cBS4asc4IN81nrbzWc',
    appId: '1:573188538666:android:36011cf9c3adfc0edede53',  // You'll get this when adding Web app
    messagingSenderId: '573188538666',
    projectId: 'emoaid-fc5ce',
    authDomain: 'emoaid-fc5ce.firebaseapp.com',
    storageBucket: 'emoaid-fc5ce.appspot.com',
    measurementId: 'G-XXXXXXXXXX',  // You'll get this with Google Analytics
  );
}