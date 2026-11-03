import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import 'welcome_screen.dart';

/// Root-level switch: shows a splash spinner while Firebase reports the
/// initial auth state, then either [WelcomeScreen] (which branches into
/// sign-in or sign-up) or the app itself (passed in as [authenticatedChild])
/// depending on whether someone's signed in. Rebuilds automatically on
/// sign-in/sign-out since it watches [AuthProvider], which listens to
/// `authStateChanges` under the hood.
class AuthGate extends StatelessWidget {
  final Widget authenticatedChild;
  const AuthGate({super.key, required this.authenticatedChild});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    switch (status) {
      case AuthStatus.unknown:
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      case AuthStatus.unauthenticated:
        return const WelcomeScreen();
      case AuthStatus.authenticated:
        return authenticatedChild;
    }
  }
}
