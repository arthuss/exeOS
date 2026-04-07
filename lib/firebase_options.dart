import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static bool get isConfigured {
    if (kIsWeb) {
      return web.apiKey.isNotEmpty;
    }
    return false;
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      if (!isConfigured) {
        throw UnsupportedError(
          'exeOS Firebase web config is missing. Provide EXEOS_FIREBASE_API_KEY at build time.',
        );
      }
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are only configured for exeOS web right now.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('EXEOS_FIREBASE_API_KEY'),
    appId: '1:856442921901:web:1d2acfd99fd5dd04303724',
    messagingSenderId: '856442921901',
    projectId: 'wallpaper-management-hub',
    authDomain: 'wallpaper-management-hub.firebaseapp.com',
    storageBucket: 'wallpaper-management-hub.firebasestorage.app',
    measurementId: 'G-Z6181PN3LS',
  );
}
