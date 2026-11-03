import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../providers/currency_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/quick_action_button.dart';
import '../../widgets/state_views.dart';
import '../../widgets/transaction_tile.dart';
import '../transactions/transaction_details_screen.dart';
import 'deposit_screen.dart';
import 'withdraw_screen.dart';

class AssetDetailsScreen extends StatelessWidget {
  final String assetId;
  const AssetDetailsScreen({super.key, required this.assetId});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final asset = wallet.assets.firstWhere((a) => a.id == assetId);
    final currency = context.watch<CurrencyProvider>();
    final txns = context
        .watch<TransactionProvider>()
        .all
        .where((t) => t.assetSymbol == asset.symbol)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('${asset.name} (${asset.symbol})')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Balance', style: AppTextStyles.bodySmall),
                    const SizedBox(height: 4),
                    Text('${Formatters.crypto(asset.balance)} ${asset.symbol}',
                        style: AppTextStyles.headingLarge),
                    Text(currency.format(asset.valueNgn), style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.md),
                    if (asset.sparkline.isNotEmpty)
                      SizedBox(
                        height: 110,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineTouchData: const LineTouchData(enabled: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for (int i = 0; i < asset.sparkline.length; i++)
                                    FlSpot(i.toDouble(), asset.sparkline[i]),
                                ],
                                isCurved: true,
                                barWidth: 2.5,
                                color: asset.isPositive ? AppColors.success : AppColors.error,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: (asset.isPositive ? AppColors.success : AppColors.error)
                                      .withValues(alpha: 0.08),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current price: ${currency.format(asset.priceNgn)}',
                            style: AppTextStyles.bodySmall),
                        Text(
                          Formatters.percent(asset.change24h),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: asset.isPositive ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Top Up',
                    icon: Icons.arrow_downward_rounded,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DepositScreen(asset: asset)),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SecondaryButton(
                    label: 'Withdraw',
                    icon: Icons.arrow_upward_rounded,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => WithdrawScreen(asset: asset)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Transaction History'),
            if (txns.isEmpty)
              const EmptyStateView(
                icon: Icons.receipt_long_rounded,
                title: 'No transactions yet',
                message: 'Transactions for this asset will appear here.',
              )
            else
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                  child: Column(
                    children: [
                      for (int i = 0; i < txns.length; i++) ...[
                        TransactionTile(
                          transaction: txns[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TransactionDetailsScreen(transaction: txns[i])),
                          ),
                        ),
                        if (i != txns.length - 1) const Divider(height: 1, indent: 58),
                      ],
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
