enum TradeSide { buy, sell }

enum TradeOrderStatus {
  awaitingPayment, // buy only: user needs to pay into your bank account
  verifying, // buy: payment submitted, awaiting confirmation. sell: payout in progress
  completed,
  cancelled,
}

extension TradeOrderStatusX on TradeOrderStatus {
  String label(TradeSide side) {
    switch (this) {
      case TradeOrderStatus.awaitingPayment:
        return 'Awaiting your payment';
      case TradeOrderStatus.verifying:
        return side == TradeSide.buy ? 'Verifying payment' : 'Sending payout';
      case TradeOrderStatus.completed:
        return side == TradeSide.buy ? 'Crypto credited' : 'Payout sent';
      case TradeOrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// A single trade executed directly against the platform's own quoted rate
/// — there is no counterparty to pick, browse, or chat with. Buying debits
/// the user's NGN payment and credits their crypto wallet; selling debits
/// their crypto wallet and pays their NGN out to their bank account.
class TradeOrder {
  final String id;
  final TradeSide side;
  final String assetSymbol;
  final double cryptoAmount;
  final double fiatAmountNgn;
  final double rateNgn;
  final DateTime createdAt;
  final Duration paymentWindow;
  final TradeOrderStatus status;

  const TradeOrder({
    required this.id,
    required this.side,
    required this.assetSymbol,
    required this.cryptoAmount,
    required this.fiatAmountNgn,
    required this.rateNgn,
    required this.createdAt,
    this.paymentWindow = const Duration(minutes: 15),
    this.status = TradeOrderStatus.awaitingPayment,
  });

  DateTime get paymentDeadline => createdAt.add(paymentWindow);

  TradeOrder copyWith({TradeOrderStatus? status}) => TradeOrder(
        id: id,
        side: side,
        assetSymbol: assetSymbol,
        cryptoAmount: cryptoAmount,
        fiatAmountNgn: fiatAmountNgn,
        rateNgn: rateNgn,
        createdAt: createdAt,
        paymentWindow: paymentWindow,
        status: status ?? this.status,
      );
}
