import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_sheets.dart';
import '../../widgets/icon_badge.dart';
import '../../widgets/main_app_bar.dart';
import 'generic_info_screen.dart';
import 'kyc_screen.dart';
import 'security_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    final body = SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
        children: [
          _ProfileHeaderCard(user: user, onTap: () => _push(context, const GenericInfoScreen(kind: InfoScreenKind.personalInfo))),
          const SizedBox(height: AppSpacing.lg),
          const _SectionLabel('Account'),
          _MenuSection(
            items: [
              _MenuItem(Icons.badge_outlined, 'Personal Information', AppColors.info,
                  () => _push(context, const GenericInfoScreen(kind: InfoScreenKind.personalInfo))),
              _MenuItem(Icons.shield_outlined, 'Security', AppColors.primary,
                  () => _push(context, const SecurityScreen())),
              _MenuItem(Icons.verified_user_outlined, 'KYC Verification', AppColors.sol,
                  () => _push(context, const KycScreen())),
              _MenuItem(Icons.credit_card_outlined, 'Payment Methods', AppColors.warning,
                  () => _push(context, const GenericInfoScreen(kind: InfoScreenKind.paymentMethods))),
              _MenuItem(Icons.account_balance_outlined, 'Bank Accounts', AppColors.btc,
                  () => _push(context, const GenericInfoScreen(kind: InfoScreenKind.bankAccounts))),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionLabel('Preferences'),
          _MenuSection(
            items: [
              _MenuItem(Icons.notifications_outlined, 'Notifications', AppColors.info,
                  () => _push(context, const GenericInfoScreen(kind: InfoScreenKind.notificationSettings))),
              _MenuItem(Icons.speed_outlined, 'Transaction Limits', AppColors.eth,
                  () => _push(context, const GenericInfoScreen(kind: InfoScreenKind.transactionLimits))),
              _MenuItem(Icons.attach_money_outlined, 'Currency', AppColors.primary,
                  () => _push(context, const GenericInfoScreen(kind: InfoScreenKind.currency))),
              _MenuItem(Icons.language_outlined, 'Language', AppColors.bnb,
                  () => _push(context, const GenericInfoScreen(kind: InfoScreenKind.language))),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionLabel('Support & Legal'),
          _MenuSection(
            items: [
              _MenuItem(Icons.help_outline_rounded, 'Help & Support', AppColors.info,
                  () => _push(context, const GenericInfoScreen(kind: InfoScreenKind.help))),
              _MenuItem(Icons.description_outlined, 'Terms & Conditions', AppColors.textSecondary,
                  () => _push(context, const GenericInfoScreen(kind: InfoScreenKind.terms))),
              _MenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', AppColors.textSecondary,
                  () => _push(context, const GenericInfoScreen(kind: InfoScreenKind.privacy))),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _MenuSection(
            items: [
              _MenuItem(
                Icons.logout_rounded,
                'Logout',
                AppColors.error,
                () async {
                  final confirmed = await showConfirmDialog(
                    context,
                    title: 'Logout',
                    message: 'Are you sure you want to log out of your account?',
                    confirmLabel: 'Logout',
                  );
                  if (confirmed && context.mounted) {
                    await context.read<AuthProvider>().signOut();
                    // AuthGate is listening for this and will swap the whole
                    // app back to LoginScreen automatically — no navigation
                    // call needed here.
                  }
                },
                labelColor: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );

    if (embedded) return body;

    return Scaffold(appBar: const MainAppBar(title: 'Profile'), body: body);
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

/// Premium-feeling header: dark navy gradient card, avatar with an emerald
/// ring and an "edit" badge, and — when relevant — an actionable KYC
/// status chip rather than a purely decorative label.
class _ProfileHeaderCard extends StatelessWidget {
  final AppUser user;
  final VoidCallback onTap;
  const _ProfileHeaderCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final needsAction = user.kycStatus == KycStatus.notVerified || user.kycStatus == KycStatus.rejected;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(BorderSide(color: AppColors.primaryLight, width: 2)),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        child: Text(
                          user.avatarInitials ?? '?',
                          style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.secondary, width: 2),
                        ),
                        child: const Icon(Icons.edit_rounded, size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName, style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(user.email, style: AppTextStyles.bodySmall.copyWith(color: Colors.white60)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.kycStatus.color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            user.kycStatus == KycStatus.verified
                                ? Icons.verified_rounded
                                : Icons.info_outline_rounded,
                            size: 12,
                            color: user.kycStatus.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.kycStatus.label,
                            style: AppTextStyles.caption.copyWith(
                              color: user.kycStatus.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (needsAction) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: SecondaryButton(
                label: 'Complete Verification',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const KycScreen()),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.4),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Color? labelColor;
  _MenuItem(this.icon, this.label, this.color, this.onTap, {this.labelColor});
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            ListTile(
              leading: IconBadge(icon: items[i].icon, color: items[i].color),
              title: Text(
                items[i].label,
                style: AppTextStyles.bodyLarge.copyWith(color: items[i].labelColor),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              onTap: items[i].onTap,
            ),
            if (i != items.length - 1) const Divider(height: 1, indent: 68),
          ],
        ],
      ),
    );
  }
}
