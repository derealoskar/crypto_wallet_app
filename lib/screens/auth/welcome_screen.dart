import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/crypto_floating_background.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// The very first thing an unauthenticated person sees — [AuthGate] shows
/// this instead of jumping straight to the login form, so there's a proper
/// "front door" with branding before asking for credentials.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: CryptoFloatingBackground()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    const Spacer(flex: 3),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                      ),
                      child: const Icon(Icons.currency_bitcoin_rounded, color: Colors.white, size: 46),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'NairaChain',
                      style: AppTextStyles.displayLarge.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Buy, sell, swap and manage crypto —\nall in one secure wallet.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
                    ),
                    const Spacer(flex: 4),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        label: 'Get Started',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: Text.rich(
                        TextSpan(
                          text: 'I already have an account  ',
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
