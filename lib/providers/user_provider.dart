import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/mock_data_service.dart';

class UserProvider extends ChangeNotifier {
  AppUser _user = MockDataService.instance.currentUser;

  AppUser get user => _user;

  void updateKycStatus(KycStatus status) {
    _user = AppUser(
      id: _user.id,
      fullName: _user.fullName,
      username: _user.username,
      email: _user.email,
      avatarInitials: _user.avatarInitials,
      kycStatus: status,
    );
    notifyListeners();
  }

  /// Merges the display name / email from the signed-in Firebase user into
  /// the (still mostly mock) profile, so Profile/Home reflect the real
  /// account instead of the hardcoded seed data. Called once from
  /// [RootShell.initState].
  void syncFromFirebaseUser({required String? fullName, required String? email}) {
    final resolvedName =
        (fullName != null && fullName.trim().isNotEmpty) ? fullName.trim() : _user.fullName;
    _user = AppUser(
      id: _user.id,
      fullName: resolvedName,
      username: _user.username,
      email: email ?? _user.email,
      avatarInitials: _initials(resolvedName),
      kycStatus: _user.kycStatus,
    );
    notifyListeners();
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
