import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A handful of crypto-flavored icon badges that drift and bob gently
/// forever — a lightweight, dependency-free stand-in for a Lottie/animated
/// illustration. Sized fractionally against whatever bounds it's given
/// (via LayoutBuilder), so it works equally well as a full-screen backdrop
/// or a compact header strip.
class CryptoFloatingBackground extends StatefulWidget {
  const CryptoFloatingBackground({super.key});

  @override
  State<CryptoFloatingBackground> createState() => _CryptoFloatingBackgroundState();
}

class _CryptoFloatingBackgroundState extends State<CryptoFloatingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _icons = [
    _FloatingIconSpec(Icons.currency_bitcoin_rounded, AppColors.btc, 0.10, 0.12, 44, 1.0, 0.0),
    _FloatingIconSpec(Icons.diamond_rounded, AppColors.eth, 0.14, 0.74, 36, 1.35, 1.4),
    _FloatingIconSpec(Icons.bolt_rounded, AppColors.sol, 0.58, 0.08, 32, 0.85, 2.6),
    _FloatingIconSpec(Icons.account_balance_wallet_rounded, AppColors.usdt, 0.64, 0.78, 38, 1.15, 0.7),
    _FloatingIconSpec(Icons.show_chart_rounded, AppColors.bnb, 0.34, 0.45, 30, 1.55, 3.4),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 360.0;
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 200.0;
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              clipBehavior: Clip.none,
              children: [for (final spec in _icons) _buildIcon(spec, w, h)],
            );
          },
        );
      },
    );
  }

  Widget _buildIcon(_FloatingIconSpec spec, double w, double h) {
    final t = _controller.value * 2 * math.pi * spec.speed + spec.phase;
    final dy = math.sin(t) * 9;
    final dx = math.cos(t * 0.6) * 5;
    return Positioned(
      top: h * spec.top + dy,
      left: w * spec.left + dx,
      child: Container(
        width: spec.size,
        height: spec.size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Icon(spec.icon, color: spec.color, size: spec.size * 0.52),
      ),
    );
  }
}

class _FloatingIconSpec {
  final IconData icon;
  final Color color;
  final double top;
  final double left;
  final double size;
  final double speed;
  final double phase;
  const _FloatingIconSpec(this.icon, this.color, this.top, this.left, this.size, this.speed, this.phase);
}
