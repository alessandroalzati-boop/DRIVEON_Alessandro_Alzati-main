// File generated automatically by the FlutterFire CLI.
// This file connects the Flutter app to the Firebase project.
//
// Command used to generate it:
// flutterfire configure --project=driveon-app-2026 --platforms=android,ios,web --yes
//
// In practice:
// - select the Firebase project "driveon-app-2026"
// - register the app for Android, iOS, and web
// - generate the keys and parameters required for Firebase.initializeApp()
//
// This file automatically selects the correct configuration
// based on the platform the app is running on (Android, iOS, or web).
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for the Firebase application.
///
/// It is used in main.dart like this:
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
///
/// This way the app uses the correct configuration for the current platform.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // If the app is running in the browser, use the web configuration.
    if (kIsWeb) {
      return web;
    }

    // Otherwise, use the platform-specific configuration for Android or iOS.
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

  // Android configuration.
  // These values were generated from the Firebase project "driveon-app-2026".
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBeaFxQF1Z_rpcMFfXDdXfRlemxvc-bygI',
    appId: '1:934619783146:android:f61158f6fb5d60f06a5c93',
    messagingSenderId: '934619783146',
    projectId: 'driveon-app-2026',
    storageBucket: 'driveon-app-2026.firebasestorage.app',
  );

  // iOS configuration.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB7JMRiPNwdk_h2AG1RFvQLUzheYsjyPjw',
    appId: '1:934619783146:ios:35d7753be3255c9d6a5c93',
    messagingSenderId: '934619783146',
    projectId: 'driveon-app-2026',
    storageBucket: 'driveon-app-2026.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  // Web configuration.
  // This is essential for running Firebase Auth and Firestore in Chrome.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCErmpU2TjABB_ABnMfhddHv7B0q3SSG-Y',
    appId: '1:934619783146:web:14d908dd2bd227ed6a5c93',
    messagingSenderId: '934619783146',
    projectId: 'driveon-app-2026',
    authDomain: 'driveon-app-2026.firebaseapp.com',
    storageBucket: 'driveon-app-2026.firebasestorage.app',
  );
}
