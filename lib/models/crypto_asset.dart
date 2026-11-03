import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A single crypto asset shown across the market list, wallet, swap and
/// convert screens. [priceNgn] and [balance] use mock values by default;
/// swap in a live Firestore-backed repository via [services/market_repository.dart].
class CryptoAsset {
  final String id;
  final String symbol;
  final String name;
  final double priceNgn;
  final double change24h; // percentage, e.g. 2.35 or -1.12
  final double balance; // amount held, in the asset's own unit
  final Color accentColor;
  final List<double> sparkline;

  /// Platform-set rates (not a live market feed) — what you charge a user
  /// buying this asset from you, and what you pay a user selling it to
  /// you. Set/updated by you (the operator), typically a small markup
  /// over [priceNgn] on the buy side and a small discount on the sell
  /// side. Every trade in the app executes against these two numbers.
  final double buyRateNgn;
  final double sellRateNgn;

  const CryptoAsset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.priceNgn,
    required this.change24h,
    required this.balance,
    required this.accentColor,
    required this.buyRateNgn,
    required this.sellRateNgn,
    this.sparkline = const [],
  });

  double get valueNgn => priceNgn * balance;

  bool get isPositive => change24h >= 0;

  /// Spread expressed as a percentage of the sell rate — useful context
  /// when you're deciding how competitive your own rates are.
  double get spreadPercent =>
      sellRateNgn == 0 ? 0 : ((buyRateNgn - sellRateNgn) / sellRateNgn) * 100;

  CryptoAsset copyWith({double? balance, double? buyRateNgn, double? sellRateNgn}) => CryptoAsset(
        id: id,
        symbol: symbol,
        name: name,
        priceNgn: priceNgn,
        change24h: change24h,
        balance: balance ?? this.balance,
        accentColor: accentColor,
        buyRateNgn: buyRateNgn ?? this.buyRateNgn,
        sellRateNgn: sellRateNgn ?? this.sellRateNgn,
        sparkline: sparkline,
      );
}

/// Fallback color lookup for assets referenced only by symbol.
Color assetAccentColor(String symbol) {
  switch (symbol.toUpperCase()) {
    case 'BTC':
      return AppColors.btc;
    case 'ETH':
      return AppColors.eth;
    case 'USDT':
      return AppColors.usdt;
    case 'USDC':
      return AppColors.usdc;
    case 'SOL':
      return AppColors.sol;
    case 'BNB':
      return AppColors.bnb;
    default:
      return AppColors.primary;
  }
}
