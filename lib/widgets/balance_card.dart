import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/formatters.dart';
import '../providers/currency_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

class BalanceCard extends StatelessWidget {
  final double balanceNgn;
  final bool hidden;
  final double portfolioChangePercent;
  final VoidCallback onToggleVisibility;
  final VoidCallback? onWalletTap;

  const BalanceCard({
    super.key,
    required this.balanceNgn,
    required this.hidden,
    required this.portfolioChangePercent,
    required this.onToggleVisibility,
    this.onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = portfolioChangePercent >= 0;
    final currency = context.watch<CurrencyProvider>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
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
              Text(
                'Total Balance',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  hidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hidden ? '${currency.symbol} • • • • • •' : currency.format(balanceNgn),
            style: AppTextStyles.displayLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      Formatters.percent(portfolioChangePercent),
                      style: AppTextStyles.caption.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onWalletTap,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                icon: const Icon(Icons.account_balance_wallet_rounded, size: 16),
                label: const Text('Wallet'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
