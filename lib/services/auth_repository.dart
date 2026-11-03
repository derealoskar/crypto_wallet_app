import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around FirebaseAuth so the rest of the app depends on
/// [AuthProvider], never `firebase_auth` directly. Extend this if you add
/// other sign-in methods later (Google, phone, etc.) — the provider and
/// screens won't need to change.
class AuthRepository {
  AuthRepository({FirebaseAuth? firebaseAuth}) : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Emits whenever the signed-in user changes (including on app start and
  /// on sign-out). `null` means signed out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Store the name on the Firebase user record itself so it's available
    // immediately without a Firestore profile document.
    await credential.user?.updateDisplayName(fullName.trim());
    await credential.user?.reload();
    return _auth.currentUser;
  }

  Future<User?> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());
}
