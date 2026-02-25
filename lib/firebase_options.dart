import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // For now, we only support Web based on the provided keys.
    // If you add Android/iOS later, we can add them here.
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBUqppj6I6U2oPS3rR_NPc6jfd_H7uq1-M',
    appId: '1:1069729456747:web:5e2fb2a3609603bdd6c72e',
    messagingSenderId: '1069729456747',
    projectId: 'restaurant-project-839ff',
    authDomain: 'restaurant-project-839ff.firebaseapp.com',
    storageBucket: 'restaurant-project-839ff.firebasestorage.app',
    measurementId: 'G-6E4WE5CM6H',
  );
}
