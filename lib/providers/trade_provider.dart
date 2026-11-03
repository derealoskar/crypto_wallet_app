import 'package:flutter/material.dart';
import '../models/trade_models.dart';
import '../services/mock_data_service.dart';

class TradeProvider extends ChangeNotifier {
  String _selectedAsset = 'USDT';
  TradeSide _side = TradeSide.buy;
  final List<TradeOrder> _orders = [];

  String get selectedAsset => _selectedAsset;
  TradeSide get side => _side;
  List<TradeOrder> get orders => List.unmodifiable(_orders);

  void selectAsset(String symbol) {
    _selectedAsset = symbol;
    notifyListeners();
  }

  void selectSide(TradeSide side) {
    _side = side;
    notifyListeners();
  }

  /// Creates a new order at the platform's current rate for [symbol].
  /// Buy orders start out waiting on the user's bank transfer; sell orders
  /// skip straight to "payout in progress" since the crypto side is
  /// settled the moment the order is placed (see [TradeOrderScreen]).
  TradeOrder createOrder({
    required TradeSide side,
    required String symbol,
    required double cryptoAmount,
    required double fiatAmountNgn,
    required double rateNgn,
  }) {
    final order = TradeOrder(
      id: 'TRD-${100000 + _orders.length}',
      side: side,
      assetSymbol: symbol,
      cryptoAmount: cryptoAmount,
      fiatAmountNgn: fiatAmountNgn,
      rateNgn: rateNgn,
      createdAt: DateTime.now(),
      status: side == TradeSide.buy ? TradeOrderStatus.awaitingPayment : TradeOrderStatus.verifying,
    );
    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  void updateOrderStatus(String orderId, TradeOrderStatus status) {
    final i = _orders.indexWhere((o) => o.id == orderId);
    if (i == -1) return;
    _orders[i] = _orders[i].copyWith(status: status);
    notifyListeners();
  }

  /// Where a buy order's payment instructions point — your business bank
  /// account. Swap for a real value (or pull from Firestore config) when
  /// you wire this up for real.
  static const supportBankAccount = 'Zenith Bank · 0111222333 · NairaChain Ltd';

  /// Convenience: current buy/sell rate pair for [symbol], as set on the
  /// asset itself in [MockDataService]. Kept here so screens have one
  /// place to ask "what's the rate right now" without reaching into
  /// WalletProvider directly.
  static ({double buy, double sell}) rateFor(String symbol) {
    final asset = MockDataService.instance.assets.firstWhere((a) => a.symbol == symbol);
    return (buy: asset.buyRateNgn, sell: asset.sellRateNgn);
  }
}
