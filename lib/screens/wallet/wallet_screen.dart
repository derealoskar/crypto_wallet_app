import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/crypto_asset_tile.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/quick_action_button.dart';
import 'asset_details_screen.dart';
import 'deposit_screen.dart';
import 'withdraw_screen.dart';

class WalletScreen extends StatelessWidget {
  final bool embedded;
  const WalletScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final currency = context.watch<CurrencyProvider>();

    final body = SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Balance',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  wallet.balanceHidden ? '${currency.symbol} • • • • • •' : currency.format(wallet.totalBalanceNgn),
                  style: AppTextStyles.displayLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: QuickActionButton(
                        icon: Icons.arrow_downward_rounded,
                        label: 'Top Up',
                        color: AppColors.primaryLight,
                        labelColor: Colors.white,
                        backgroundAlpha: 0.22,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DepositScreen(asset: wallet.assets.first)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: QuickActionButton(
                        icon: Icons.arrow_upward_rounded,
                        label: 'Withdraw',
                        color: AppColors.primaryLight,
                        labelColor: Colors.white,
                        backgroundAlpha: 0.22,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => WithdrawScreen(asset: wallet.assets.first)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: QuickActionButton(
                        icon: Icons.north_east_rounded,
                        label: 'Send',
                        color: AppColors.primaryLight,
                        labelColor: Colors.white,
                        backgroundAlpha: 0.22,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => WithdrawScreen(asset: wallet.assets.first)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: QuickActionButton(
                        icon: Icons.south_west_rounded,
                        label: 'Receive',
                        color: AppColors.primaryLight,
                        labelColor: Colors.white,
                        backgroundAlpha: 0.22,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DepositScreen(asset: wallet.assets.first)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Your Assets'),
          Builder(
            builder: (context) {
              final sorted = [...wallet.assets]..sort((a, b) => b.valueNgn.compareTo(a.valueNgn));
              final total = wallet.totalBalanceNgn;
              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                  child: Column(
                    children: [
                      for (int i = 0; i < sorted.length; i++) ...[
                        CryptoAssetTile(
                          asset: sorted[i],
                          showBalance: true,
                          portfolioShare: total > 0 ? sorted[i].valueNgn / total : 0,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AssetDetailsScreen(assetId: sorted[i].id)),
                          ),
                        ),
                        if (i != sorted.length - 1) const Divider(height: 1, indent: 52),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );

    if (embedded) return body;

    return Scaffold(
      appBar: const MainAppBar(title: 'Wallet'),
      body: body,
    );
  }
}
