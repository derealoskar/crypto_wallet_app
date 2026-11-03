import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../models/trade_models.dart';
import '../../models/transaction_model.dart';
import '../../providers/trade_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_sheets.dart';
import '../../widgets/state_views.dart';

/// Tracks a single order end to end. Buy orders wait on the user's bank
/// transfer, then simulate verification before crediting the wallet.
/// Sell orders (crypto already escrowed in [TradeScreen]) simulate a
/// payout before marking the NGN as sent. There's no counterparty here —
/// every state transition is between the user and the platform itself.
class TradeOrderScreen extends StatefulWidget {
  final TradeOrder order;
  const TradeOrderScreen({super.key, required this.order});

  @override
  State<TradeOrderScreen> createState() => _TradeOrderScreenState();
}

class _TradeOrderScreenState extends State<TradeOrderScreen> {
  late TradeOrder _order = widget.order;
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;
  bool _processing = false;

  bool get _isBuy => _order.side == TradeSide.buy;

  @override
  void initState() {
    super.initState();
    if (_isBuy) {
      _remaining = _order.paymentDeadline.difference(DateTime.now());
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final left = _order.paymentDeadline.difference(DateTime.now());
        if (!mounted) return;
        setState(() => _remaining = left.isNegative ? Duration.zero : left);
        if (left.isNegative && _order.status == TradeOrderStatus.awaitingPayment) {
          _updateStatus(TradeOrderStatus.cancelled);
        }
      });
    } else {
      // Sell orders have nothing for the user to do — kick off the
      // simulated payout right away.
      _processPayout();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _updateStatus(TradeOrderStatus status) {
    context.read<TradeProvider>().updateOrderStatus(_order.id, status);
    if (!mounted) return;
    setState(() => _order = _order.copyWith(status: status));
  }

  Future<void> _confirmPaymentMade() async {
    _countdownTimer?.cancel();
    _updateStatus(TradeOrderStatus.verifying);
    setState(() => _processing = true);
    // Simulates the time it'd take you (or a Cloud Function watching your
    // bank webhook) to confirm the transfer actually landed.
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    context.read<WalletProvider>().adjustBalance(_order.assetSymbol, _order.cryptoAmount);
    context.read<TransactionProvider>().addTransaction(
          TransactionModel(
            id: 'trd-${DateTime.now().millisecondsSinceEpoch}',
            type: TransactionType.buy,
            assetSymbol: _order.assetSymbol,
            amount: _order.cryptoAmount,
            fiatAmountNgn: _order.fiatAmountNgn,
            date: DateTime.now(),
            status: TransactionStatus.completed,
            note: 'Order #${_order.id}',
          ),
        );
    setState(() => _processing = false);
    _updateStatus(TradeOrderStatus.completed);
  }

  Future<void> _processPayout() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    context.read<TransactionProvider>().addTransaction(
          TransactionModel(
            id: 'trd-${DateTime.now().millisecondsSinceEpoch}',
            type: TransactionType.sell,
            assetSymbol: _order.assetSymbol,
            amount: _order.cryptoAmount,
            fiatAmountNgn: _order.fiatAmountNgn,
            date: DateTime.now(),
            status: TransactionStatus.completed,
            note: 'Order #${_order.id} · payout to bank account on file',
          ),
        );
    setState(() => _processing = false);
    _updateStatus(TradeOrderStatus.completed);
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Cancel Order',
      message: 'Cancel this order? You can start a new one any time at the current rate.',
      confirmLabel: 'Cancel Order',
    );
    if (confirmed) _updateStatus(TradeOrderStatus.cancelled);
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.id}')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusBanner(order: order, remaining: _remaining, processing: _processing),
              const SizedBox(height: AppSpacing.md),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      SummaryRow(
                        label: _isBuy ? 'You pay' : 'You get paid',
                        value: Formatters.ngn(order.fiatAmountNgn, decimals: false),
                      ),
                      SummaryRow(
                        label: _isBuy ? 'You receive' : 'You sold',
                        value: '${Formatters.crypto(order.cryptoAmount)} ${order.assetSymbol}',
                      ),
                      SummaryRow(
                        label: 'Rate',
                        value: '${Formatters.ngn(order.rateNgn, decimals: false)} / ${order.assetSymbol}',
                      ),
                      SummaryRow(label: 'Placed', value: Formatters.date(order.createdAt)),
                    ],
                  ),
                ),
              ),
              if (_isBuy && order.status == TradeOrderStatus.awaitingPayment) ...[
                const SizedBox(height: AppSpacing.md),
                _BankDetailsCard(amountNgn: order.fiatAmountNgn, orderId: order.id),
              ],
              if (!_isBuy) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.account_balance_rounded, size: 18, color: AppColors.info),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Payout is sent to the bank account on file under Profile → Bank Accounts.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    switch (_order.status) {
      case TradeOrderStatus.awaitingPayment:
        return Column(
          children: [
            PrimaryButton(
              label: 'I Have Made Payment',
              onPressed: _confirmPaymentMade,
            ),
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(label: 'Cancel Order', onPressed: _cancelOrder),
          ],
        );
      case TradeOrderStatus.verifying:
        return const SizedBox.shrink();
      case TradeOrderStatus.completed:
        return SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: 'Done',
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        );
      case TradeOrderStatus.cancelled:
        return SizedBox(
          width: double.infinity,
          child: SecondaryButton(
            label: 'Back to Trade',
            onPressed: () => Navigator.of(context).pop(),
          ),
        );
    }
  }
}

class _BankDetailsCard extends StatelessWidget {
  final double amountNgn;
  final String orderId;
  const _BankDetailsCard({required this.amountNgn, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pay Into', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  TradeProvider.supportBankAccount,
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 18),
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: TradeProvider.supportBankAccount));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account details copied')),
                  );
                },
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Amount', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
              Text(
                Formatters.ngn(amountNgn, decimals: false),
                style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Use "$orderId" as your transfer narration/reference so we can match your payment quickly.',
            style: AppTextStyles.caption.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final TradeOrder order;
  final Duration remaining;
  final bool processing;

  const _StatusBanner({required this.order, required this.remaining, required this.processing});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (order.status) {
      case TradeOrderStatus.awaitingPayment:
        color = AppColors.warning;
        break;
      case TradeOrderStatus.verifying:
        color = AppColors.info;
        break;
      case TradeOrderStatus.completed:
        color = AppColors.success;
        break;
      case TradeOrderStatus.cancelled:
        color = AppColors.textMuted;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          if (processing)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          else
            Icon(
              order.status == TradeOrderStatus.completed
                  ? Icons.check_circle_rounded
                  : order.status == TradeOrderStatus.cancelled
                      ? Icons.cancel_rounded
                      : Icons.lock_clock_rounded,
              color: color,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              order.status.label(order.side),
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
            ),
          ),
          if (order.status == TradeOrderStatus.awaitingPayment)
            Text(
              Formatters.countdown(remaining),
              style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
            ),
        ],
      ),
    );
  }
}
