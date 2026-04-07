import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are only configured for exeOS web right now.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCCgh4qUUD8F9cWh2gBB7-IcMg260QDEts',
    appId: '1:856442921901:web:1d2acfd99fd5dd04303724',
    messagingSenderId: '856442921901',
    projectId: 'wallpaper-management-hub',
    authDomain: 'wallpaper-management-hub.firebaseapp.com',
    storageBucket: 'wallpaper-management-hub.firebasestorage.app',
    measurementId: 'G-Z6181PN3LS',
  );
}
