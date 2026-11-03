import 'package:flutter/material.dart';
import '../core/formatters.dart';
import '../models/trade_models.dart';
import '../providers/trade_provider.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// The app's primary action, so it gets the most visual weight on Home:
/// bold gradients, a soft pulsing glow behind each icon, and the live
/// rate quoted right on the card — tap either side to jump straight into
/// [TradeScreen] at that rate.
class TradeHeroBanner extends StatefulWidget {
  final String symbol;
  final ValueChanged<TradeSide> onTap;

  const TradeHeroBanner({super.key, required this.symbol, required this.onTap});

  @override
  State<TradeHeroBanner> createState() => _TradeHeroBannerState();
}

class _TradeHeroBannerState extends State<TradeHeroBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rate = TradeProvider.rateFor(widget.symbol);
    return Row(
      children: [
        Expanded(
          child: _TradeCard(
            label: 'Buy ${widget.symbol}',
            subtitle: 'from ${Formatters.ngn(rate.buy, decimals: false)}',
            icon: Icons.trending_up_rounded,
            colors: const [Color(0xFF17B978), Color(0xFF0B7A4C)],
            glow: _glow,
            onTap: () => widget.onTap(TradeSide.buy),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _TradeCard(
            label: 'Sell ${widget.symbol}',
            subtitle: 'up to ${Formatters.ngn(rate.sell, decimals: false)}',
            icon: Icons.trending_down_rounded,
            colors: const [Color(0xFFEF5A50), Color(0xFFB5342C)],
            glow: _glow,
            onTap: () => widget.onTap(TradeSide.sell),
          ),
        ),
      ],
    );
  }
}

class _TradeCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final Animation<double> glow;
  final VoidCallback onTap;

  const _TradeCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.glow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          height: 136,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Soft pulsing glow — the "good animation" behind the icon.
                Positioned(
                  right: -18,
                  top: -18,
                  child: AnimatedBuilder(
                    animation: glow,
                    builder: (context, child) {
                      final t = glow.value;
                      return Opacity(
                        opacity: 0.14 + (t * 0.18),
                        child: Transform.scale(
                          scale: 0.85 + (t * 0.3),
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.88)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
