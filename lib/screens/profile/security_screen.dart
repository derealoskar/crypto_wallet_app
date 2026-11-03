import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_sheets.dart';
import '../../widgets/icon_badge.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometric = true;
  bool _twoFactor = false;
  bool _withdrawalConfirmation = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _sectionLabel('Authentication'),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const IconBadge(icon: Icons.lock_outline_rounded, color: AppColors.info),
                    title: Text('Change Password', style: AppTextStyles.bodyLarge),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 68),
                  ListTile(
                    leading: const IconBadge(icon: Icons.pin_outlined, color: AppColors.warning),
                    title: Text('Transaction PIN', style: AppTextStyles.bodyLarge),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 68),
                  SwitchListTile(
                    secondary: const IconBadge(icon: Icons.fingerprint_rounded, color: AppColors.primary),
                    title: Text('Biometric Authentication', style: AppTextStyles.bodyLarge),
                    subtitle: const Text('Use Face ID / fingerprint to sign in'),
                    value: _biometric,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _biometric = v),
                  ),
                  const Divider(height: 1, indent: 68),
                  SwitchListTile(
                    secondary: const IconBadge(icon: Icons.verified_user_outlined, color: AppColors.sol),
                    title: Text('Two-Factor Authentication', style: AppTextStyles.bodyLarge),
                    subtitle: const Text('Extra verification code at login'),
                    value: _twoFactor,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _twoFactor = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _sectionLabel('Transactions'),
            Card(
              margin: EdgeInsets.zero,
              child: SwitchListTile(
                secondary: const IconBadge(icon: Icons.shield_outlined, color: AppColors.error),
                title: Text('Require confirmation for withdrawals', style: AppTextStyles.bodyLarge),
                value: _withdrawalConfirmation,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => setState(() => _withdrawalConfirmation = v),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _sectionLabel('Devices & Activity'),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const IconBadge(icon: Icons.history_rounded, color: AppColors.eth),
                    title: Text('Login Activity', style: AppTextStyles.bodyLarge),
                    subtitle: const Text('Chrome · Lagos, Nigeria · Today'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 68),
                  ListTile(
                    leading: const IconBadge(icon: Icons.devices_rounded, color: AppColors.btc),
                    title: Text('Trusted Devices', style: AppTextStyles.bodyLarge),
                    subtitle: const Text('2 devices'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await showConfirmDialog(
                    context,
                    title: 'Sign out other sessions',
                    message: 'This will log you out on every other device.',
                    confirmLabel: 'Sign out',
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                label: const Text('Sign out of all other sessions',
                    style: TextStyle(color: AppColors.error)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.4),
        ),
      );
}
