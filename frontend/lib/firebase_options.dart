// File generated manually since flutterfire CLI is unavailable.
// Paste your Web configuration from the Firebase Console here!

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // Return null for other platforms (Android/iOS) so they
    // correctly fall back to using their native configuration files
    // (google-services.json / GoogleService-Info.plist).
    return null;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAquX7EKZyVMUMQ5keC4UmBdgaQsa6ucYk',
    appId: '1:635643488049:web:b37eabd977c879de47b210',
    messagingSenderId: '635643488049',
    projectId: 'bitbrains-ac840',
    authDomain: 'bitbrains-ac840.firebaseapp.com',
    storageBucket: 'bitbrains-ac840.firebasestorage.app',
    measurementId: 'G-PBYEWVHMBP',
  );
}
