import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../core/formatters.dart';
import '../models/crypto_asset.dart';
import '../providers/currency_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// A continuously auto-scrolling strip of price chips — a livelier, more
/// "alive" alternative to a static market list. The item list is doubled
/// and the scroll position wraps seamlessly, so it reads as an endless
/// ticker rather than a list the user has to scroll themselves.
class CryptoTickerBanner extends StatefulWidget {
  final List<CryptoAsset> assets;
  const CryptoTickerBanner({super.key, required this.assets});

  @override
  State<CryptoTickerBanner> createState() => _CryptoTickerBannerState();
}

class _CryptoTickerBannerState extends State<CryptoTickerBanner>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final Ticker _ticker;
  double _offset = 0;
  static const _pxPerSecond = 28.0;

  @override
  void initState() {
    super.initState();
    Duration lastElapsed = Duration.zero;
    _ticker = createTicker((elapsed) {
      if (!_scrollController.hasClients) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll <= 0) {
        lastElapsed = elapsed;
        return;
      }
      final deltaSeconds = (elapsed - lastElapsed).inMicroseconds / Duration.microsecondsPerSecond;
      lastElapsed = elapsed;
      _offset += _pxPerSecond * deltaSeconds;
      // Half the (doubled) list's width is one full loop — wrap there so
      // the seam between the two copies is invisible.
      final loopPoint = maxScroll / 2 <= 0 ? maxScroll : maxScroll / 2;
      if (_offset >= loopPoint) _offset -= loopPoint;
      _scrollController.jumpTo(_offset);
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assets.isEmpty) return const SizedBox.shrink();
    final currency = context.watch<CurrencyProvider>();
    // Doubled so the loop wraps seamlessly instead of snapping back to start.
    final items = [...widget.assets, ...widget.assets];

    return SizedBox(
      height: 96,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _TickerChip(asset: items[i], currency: currency),
      ),
    );
  }
}

class _TickerChip extends StatelessWidget {
  final CryptoAsset asset;
  final CurrencyProvider currency;
  const _TickerChip({required this.asset, required this.currency});

  @override
  Widget build(BuildContext context) {
    final positive = asset.isPositive;
    return Container(
      width: 150,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [asset.accentColor.withValues(alpha: 0.12), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: asset.accentColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: asset.accentColor.withValues(alpha: 0.16),
                child: Text(
                  asset.symbol.characters.first,
                  style: AppTextStyles.caption.copyWith(
                    color: asset.accentColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(asset.symbol, style: AppTextStyles.label),
              const Spacer(),
              Icon(
                positive ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                color: positive ? AppColors.success : AppColors.error,
                size: 18,
              ),
            ],
          ),
          const Spacer(),
          Text(currency.format(asset.priceNgn), style: AppTextStyles.bodyMedium),
          Text(
            Formatters.percent(asset.change24h),
            style: AppTextStyles.caption.copyWith(
              color: positive ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
