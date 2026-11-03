import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'firebase_options.dart';

// IMPORTANT — before this file will compile, generate `firebase_options.dart`:
//
//   1. Create your Firebase project (or use one from the console) and, in it,
//      enable Authentication -> Sign-in method -> Email/Password.
//   2. Install the CLIs once: `dart pub global activate flutterfire_cli`
//      (requires the Firebase CLI too: `npm install -g firebase-tools`,
//      then `firebase login`).
//   3. From this project's root, run: `flutterfire configure`
//      and pick the Firebase project you just created. This generates
//      `lib/firebase_options.dart`, imported above — the app won't build
//      until that file exists.
//   4. `flutter pub get`, then `flutter run`.
//
// From here on, sign-up/sign-in/sign-out all just work: see
// lib/providers/auth_provider.dart, lib/services/auth_repository.dart, and
// lib/screens/auth/.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CryptoWalletApp());
}
