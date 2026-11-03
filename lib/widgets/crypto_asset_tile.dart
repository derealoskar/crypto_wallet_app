import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/formatters.dart';
import '../models/crypto_asset.dart';
import '../providers/currency_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

class CryptoAssetTile extends StatelessWidget {
  final CryptoAsset asset;
  final VoidCallback? onTap;
  final bool showBalance;

  /// Fraction (0–1) of the total portfolio this asset represents. Only
  /// rendered when [showBalance] is true and the asset is actually held —
  /// draws a thin allocation bar under the row, the kind of detail that
  /// reads as "a real wallet" rather than a plain list.
  final double? portfolioShare;

  const CryptoAssetTile({
    super.key,
    required this.asset,
    this.onTap,
    this.showBalance = false,
    this.portfolioShare,
  });

  @override
  Widget build(BuildContext context) {
    final positive = asset.isPositive;
    final currency = context.watch<CurrencyProvider>();
    final held = asset.balance > 0;
    final muted = showBalance && !held;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: asset.accentColor.withValues(alpha: muted ? 0.08 : 0.14),
                  child: Text(
                    asset.symbol.characters.first,
                    style: AppTextStyles.label.copyWith(
                      color: muted ? AppColors.textMuted : asset.accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: muted ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(asset.symbol, style: AppTextStyles.bodySmall),
                          if (showBalance) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: (positive ? AppColors.success : AppColors.error)
                                    .withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                Formatters.percent(asset.change24h),
                                style: AppTextStyles.caption.copyWith(
                                  color: positive ? AppColors.success : AppColors.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (!showBalance && asset.sparkline.isNotEmpty)
                  SizedBox(
                    width: 56,
                    height: 28,
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
                            barWidth: 2,
                            color: positive ? AppColors.success : AppColors.error,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!showBalance) const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      showBalance
                          ? (held ? currency.format(asset.valueNgn) : 'Not held')
                          : currency.format(asset.priceNgn),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: muted ? AppColors.textMuted : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      showBalance
                          ? (held ? '${Formatters.crypto(asset.balance)} ${asset.symbol}' : 'Tap to buy')
                          : Formatters.percent(asset.change24h),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: showBalance
                            ? (held ? AppColors.textSecondary : AppColors.primary)
                            : (positive ? AppColors.success : AppColors.error),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (showBalance && held && (portfolioShare ?? 0) > 0) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 52),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: portfolioShare!.clamp(0, 1),
                    minHeight: 4,
                    backgroundColor: AppColors.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation(asset.accentColor),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
