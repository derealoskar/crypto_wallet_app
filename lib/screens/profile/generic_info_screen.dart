import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/icon_badge.dart';
import '../../widgets/state_views.dart';
import '../support/live_chat_screen.dart';

enum InfoScreenKind {
  personalInfo,
  paymentMethods,
  bankAccounts,
  notificationSettings,
  transactionLimits,
  currency,
  language,
  help,
  terms,
  privacy,
}

/// A single reusable screen for the simpler profile menu destinations.
/// Each variant renders mock, realistic content for its section so the
/// navigation from Profile is fully wired, without a bespoke screen per item.
class GenericInfoScreen extends StatelessWidget {
  final InfoScreenKind kind;
  const GenericInfoScreen({super.key, required this.kind});

  String get _title {
    switch (kind) {
      case InfoScreenKind.personalInfo:
        return 'Personal Information';
      case InfoScreenKind.paymentMethods:
        return 'Payment Methods';
      case InfoScreenKind.bankAccounts:
        return 'Bank Accounts';
      case InfoScreenKind.notificationSettings:
        return 'Notification Settings';
      case InfoScreenKind.transactionLimits:
        return 'Transaction Limits';
      case InfoScreenKind.currency:
        return 'Currency';
      case InfoScreenKind.language:
        return 'Language';
      case InfoScreenKind.help:
        return 'Help & Support';
      case InfoScreenKind.terms:
        return 'Terms & Conditions';
      case InfoScreenKind.privacy:
        return 'Privacy Policy';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (kind) {
      case InfoScreenKind.personalInfo:
        return _personalInfo(context);
      case InfoScreenKind.paymentMethods:
        return _paymentMethods();
      case InfoScreenKind.bankAccounts:
        return _bankAccounts();
      case InfoScreenKind.notificationSettings:
        return _toggleList(const [
          'Transaction alerts',
          'Trade order updates',
          'Security alerts',
          'Promotions & offers',
        ]);
      case InfoScreenKind.transactionLimits:
        return _transactionLimits();
      case InfoScreenKind.currency:
        return _currencyList(context);
      case InfoScreenKind.language:
        return _selectableList(const ['English', 'French', 'Hausa', 'Yoruba', 'Igbo'], 0);
      case InfoScreenKind.help:
        return _helpCenter(context);
      case InfoScreenKind.terms:
        return _legalText(
          'By using this application you agree to our terms of service, including trading rules, '
          'fee schedules, KYC requirements, and trade execution at our quoted rates. '
          'Full legal text will be provided by your compliance team before launch.',
        );
      case InfoScreenKind.privacy:
        return _legalText(
          'We collect the minimum information required to verify your identity and process '
          'transactions. Your data is encrypted at rest and in transit, and is never sold to '
          'third parties. Full legal text will be provided by your compliance team before launch.',
        );
    }
  }

  Widget _personalInfo(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _infoTile(Icons.person_outline_rounded, AppColors.info, 'Full Name', user.fullName),
        _infoTile(Icons.alternate_email_rounded, AppColors.primary, 'Username', user.username),
        _infoTile(Icons.mail_outline_rounded, AppColors.sol, 'Email', user.email),
        _infoTile(Icons.phone_outlined, AppColors.warning, 'Phone Number', '+234 803 456 7890'),
        _infoTile(Icons.cake_outlined, AppColors.btc, 'Date of Birth', 'Not set'),
        _infoTile(Icons.public_rounded, AppColors.eth, 'Country', 'Nigeria'),
      ],
    );
  }

  Widget _infoTile(IconData icon, Color color, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: IconBadge(icon: icon, color: color),
        title: Text(label, style: AppTextStyles.bodySmall),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(value, style: AppTextStyles.bodyLarge),
        ),
        trailing: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textMuted),
      ),
    );
  }

  Widget _paymentMethods() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _methodTile(Icons.account_balance_rounded, AppColors.primary, 'Bank Transfer', 'GTBank •••• 4521'),
        _methodTile(Icons.account_balance_wallet_rounded, AppColors.info, 'Opay', '•••• 8890'),
        _methodTile(Icons.account_balance_wallet_rounded, AppColors.sol, 'PalmPay', '•••• 1123'),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Payment Method'),
        ),
      ],
    );
  }

  Widget _methodTile(IconData icon, Color color, String title, String subtitle, {VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: IconBadge(icon: icon, color: color),
        title: Text(title, style: AppTextStyles.bodyLarge),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }

  Widget _bankAccounts() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _methodTile(Icons.account_balance_rounded, AppColors.primary, 'Zenith Bank', '0123456789 · Oscar E.'),
        _methodTile(Icons.account_balance_rounded, AppColors.info, 'GTBank', '0987654321 · Oscar E.'),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Bank Account'),
        ),
      ],
    );
  }

  Widget _transactionLimits() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                SummaryRow(label: 'Daily limit', value: '₦2,000,000'),
                SummaryRow(label: 'Monthly limit', value: '₦20,000,000'),
                SummaryRow(label: 'Single trade order', value: '₦5,000,000'),
                SummaryRow(label: 'Daily withdrawal', value: '₦1,000,000'),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Complete KYC verification to increase your limits.',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _toggleList(List<String> labels) {
    return StatefulBuilder(
      builder: (context, setState) {
        final values = List<bool>.filled(labels.length, true);
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            for (int i = 0; i < labels.length; i++)
              SwitchListTile(
                title: Text(labels[i], style: AppTextStyles.bodyLarge),
                value: values[i],
                activeThumbColor: AppColors.primary,
                onChanged: (v) => setState(() => values[i] = v),
              ),
          ],
        );
      },
    );
  }

  Widget _currencyList(BuildContext context) {
    const labels = {
      'NGN': 'NGN - Nigerian Naira',
      'USD': 'USD - US Dollar',
      'EUR': 'EUR - Euro',
      'GBP': 'GBP - British Pound',
    };
    final currency = context.watch<CurrencyProvider>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Controls how asset balances and prices are displayed on Home and '
            'Wallet. Trades and payments still settle in NGN either way.',
            style: AppTextStyles.bodySmall,
          ),
        ),
        for (final code in currency.supportedCurrencies)
          RadioListTile<String>(
            value: code,
            groupValue: currency.currency,
            activeColor: AppColors.primary,
            title: Text(labels[code] ?? code, style: AppTextStyles.bodyLarge),
            onChanged: (v) => context.read<CurrencyProvider>().setCurrency(v ?? code),
          ),
      ],
    );
  }

  Widget _selectableList(List<String> options, int selectedIndex) {
    return StatefulBuilder(
      builder: (context, setState) {
        int selected = selectedIndex;
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            for (int i = 0; i < options.length; i++)
              RadioListTile<int>(
                value: i,
                groupValue: selected,
                activeColor: AppColors.primary,
                title: Text(options[i], style: AppTextStyles.bodyLarge),
                onChanged: (v) => setState(() => selected = v ?? selected),
              ),
          ],
        );
      },
    );
  }

  Widget _helpCenter(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _methodTile(
          Icons.chat_bubble_outline_rounded,
          AppColors.primary,
          'Live Chat',
          'Talk to support',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LiveChatScreen()),
          ),
        ),
        _methodTile(Icons.mail_outline_rounded, AppColors.info, 'Email Support', 'support@example.com'),
        _methodTile(Icons.article_outlined, AppColors.warning, 'FAQs', 'Common questions answered'),
      ],
    );
  }

  Widget _legalText(String text) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(text, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
