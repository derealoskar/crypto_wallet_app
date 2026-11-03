import 'package:flutter/material.dart';
import '../models/crypto_asset.dart';
import '../services/mock_data_service.dart';

class WalletProvider extends ChangeNotifier {
  WalletProvider() {
    _assets = MockDataService.instance.assets;
  }

  late List<CryptoAsset> _assets;
  bool _balanceHidden = false;

  List<CryptoAsset> get assets => _assets;
  bool get balanceHidden => _balanceHidden;

  double get totalBalanceNgn =>
      _assets.fold(0.0, (sum, a) => sum + a.valueNgn);

  CryptoAsset assetBySymbol(String symbol) =>
      _assets.firstWhere((a) => a.symbol == symbol, orElse: () => _assets.first);

  void toggleBalanceVisibility() {
    _balanceHidden = !_balanceHidden;
    notifyListeners();
  }

  /// Applies a completed trade's crypto-side effect: positive [delta]
  /// credits the wallet (a completed buy), negative debits it (a
  /// completed sell). Called from [TradeOrderScreen] once an order
  /// finishes — this is the only place balances change outside of the
  /// mock seed data.
  void adjustBalance(String symbol, double delta) {
    final i = _assets.indexWhere((a) => a.symbol == symbol);
    if (i == -1) return;
    final updated = List<CryptoAsset>.of(_assets);
    updated[i] = updated[i].copyWith(balance: updated[i].balance + delta);
    _assets = updated;
    notifyListeners();
  }
}
