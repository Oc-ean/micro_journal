import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

mixin DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: dotenv.env['ANDROID_API_KEY']!,
        appId: dotenv.env['ANDROID_APP_ID']!,
        messagingSenderId: dotenv.env['ANDROID_MESSAGING_SENDER_ID']!,
        projectId: dotenv.env['ANDROID_PROJECT_ID']!,
        storageBucket: dotenv.env['ANDROID_STORAGE_BUCKET'],
      );

  static FirebaseOptions get ios => throw UnimplementedError();
  static FirebaseOptions get web => throw UnimplementedError();
}
