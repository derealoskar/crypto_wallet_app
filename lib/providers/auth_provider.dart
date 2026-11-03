import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Single source of truth for auth state. [AuthGate] watches [status] to
/// decide between the login flow and the app shell; screens call
/// [register]/[signIn]/[signOut] and read [submitting]/[errorMessage] to
/// drive their own UI, without ever touching `firebase_auth` directly.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository}) : _repository = repository ?? AuthRepository() {
    _authSub = _repository.authStateChanges.listen(_onAuthStateChanged);
  }

  final AuthRepository _repository;
  late final StreamSubscription<User?> _authSub;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  bool _submitting = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  bool get submitting => _submitting;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  void _onAuthStateChanged(User? user) {
    _user = user;
    _status = user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _run(() => _repository.register(fullName: fullName, email: email, password: password));
  }

  Future<bool> signIn({required String email, required String password}) {
    return _run(() => _repository.signIn(email: email, password: password));
  }

  Future<void> signOut() => _repository.signOut();

  Future<bool> sendPasswordResetEmail(String email) async {
    _submitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.sendPasswordResetEmail(email);
      _submitting = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _submitting = false;
      _errorMessage = _friendlyMessage(e);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(Future<User?> Function() action) async {
    _submitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      _submitting = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _submitting = false;
      _errorMessage = _friendlyMessage(e);
      notifyListeners();
      return false;
    } catch (_) {
      _submitting = false;
      _errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'operation-not-allowed':
        return 'Email/password sign-in isn\'t enabled for this project yet.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}
