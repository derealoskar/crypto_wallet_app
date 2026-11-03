import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../models/crypto_asset.dart';
import '../../models/trade_models.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../trade/trade_screen.dart';

/// Opened from the app bar's rate icon. Shows every asset's current
/// platform-quoted buy/sell rate side by side — not a live market feed,
/// just what you're charging/paying right now — with a quick way to jump
/// straight into a trade at that rate.
class RatesScreen extends StatelessWidget {
  const RatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assets = context.watch<WalletProvider>().assets;

    return Scaffold(
      appBar: AppBar(title: const Text('Rates')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'These are our own quoted rates, not a live market feed — they '
                      'update periodically and every trade executes at the rate shown here.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final asset in assets) _RateRow(asset: asset),
          ],
        ),
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  final CryptoAsset asset;
  const _RateRow({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: asset.accentColor.withValues(alpha: 0.14),
                  child: Text(asset.symbol.characters.first,
                      style: AppTextStyles.label.copyWith(color: asset.accentColor)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(asset.name, style: AppTextStyles.bodyLarge),
                      Text(asset.symbol, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Text(
                  '${asset.spreadPercent.toStringAsFixed(2)}% spread',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _RateTile(
                    label: 'We sell (you buy)',
                    value: Formatters.ngn(asset.buyRateNgn, decimals: false),
                    color: AppColors.error,
                    onTap: () => _openTrade(context, TradeSide.buy),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _RateTile(
                    label: 'We buy (you sell)',
                    value: Formatters.ngn(asset.sellRateNgn, decimals: false),
                    color: AppColors.success,
                    onTap: () => _openTrade(context, TradeSide.sell),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openTrade(BuildContext context, TradeSide side) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TradeScreen(initialSide: side, initialAsset: asset.symbol),
      ),
    );
  }
}

class _RateTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _RateTile({required this.label, required this.value, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.bodyMedium.copyWith(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
