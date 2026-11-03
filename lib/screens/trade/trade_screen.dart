import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../models/trade_models.dart';
import '../../providers/trade_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_sheets.dart';
import '../../widgets/state_views.dart';
import 'trade_order_screen.dart';

/// Buy from or sell directly to the platform at its own quoted rate — no
/// merchant list, no counterparty to pick. One rate, one order.
class TradeScreen extends StatefulWidget {
  final TradeSide initialSide;
  final String? initialAsset;
  const TradeScreen({super.key, this.initialSide = TradeSide.buy, this.initialAsset});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  late TradeSide _side = widget.initialSide;
  late String _symbol = widget.initialAsset ?? 'USDT';
  final _ngnController = TextEditingController();
  final _cryptoController = TextEditingController();
  bool _editingCrypto = false;
  static const _minNgn = 1000.0;

  double get _rate {
    final r = TradeProvider.rateFor(_symbol);
    return _side == TradeSide.buy ? r.buy : r.sell;
  }

  @override
  void dispose() {
    _ngnController.dispose();
    _cryptoController.dispose();
    super.dispose();
  }

  void _onNgnChanged(String v) {
    final ngn = double.tryParse(v) ?? 0;
    final crypto = _rate == 0 ? 0.0 : ngn / _rate;
    _cryptoController.text = crypto == 0 ? '' : Formatters.crypto(crypto);
    setState(() {});
  }

  void _onCryptoChanged(String v) {
    final crypto = double.tryParse(v) ?? 0;
    final ngn = crypto * _rate;
    _ngnController.text = ngn == 0 ? '' : ngn.toStringAsFixed(0);
    setState(() {});
  }

  void _recalculate() {
    if (_editingCrypto) {
      _onCryptoChanged(_cryptoController.text);
    } else {
      _onNgnChanged(_ngnController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final asset = wallet.assetBySymbol(_symbol);
    final isBuy = _side == TradeSide.buy;
    final ngnAmount = double.tryParse(_ngnController.text) ?? 0;
    final cryptoAmount = double.tryParse(_cryptoController.text) ?? 0;
    final insufficientBalance = !isBuy && cryptoAmount > asset.balance;

    return Scaffold(
      appBar: AppBar(title: const Text('Trade')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SegmentButton(
                      label: 'Buy',
                      selected: isBuy,
                      color: AppColors.success,
                      onTap: () => setState(() {
                        _side = TradeSide.buy;
                        _recalculate();
                      }),
                    ),
                  ),
                  Expanded(
                    child: _SegmentButton(
                      label: 'Sell',
                      selected: !isBuy,
                      color: AppColors.error,
                      onTap: () => setState(() {
                        _side = TradeSide.sell;
                        _recalculate();
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _symbol,
              decoration: const InputDecoration(labelText: 'Asset'),
              items: wallet.assets
                  .map((a) => DropdownMenuItem(value: a.symbol, child: Text('${a.name} (${a.symbol})')))
                  .toList(),
              onChanged: (v) => setState(() {
                _symbol = v ?? _symbol;
                _recalculate();
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      isBuy ? Icons.sell_rounded : Icons.storefront_rounded,
                      color: isBuy ? AppColors.error : AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isBuy ? 'Our current sell rate' : 'Our current buy rate',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                    Text(
                      '${Formatters.ngn(_rate, decimals: false)} / $_symbol',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isBuy ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    TextField(
                      controller: _ngnController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) {
                        _editingCrypto = false;
                        _onNgnChanged(v);
                      },
                      decoration: InputDecoration(
                        labelText: isBuy ? 'You pay (NGN)' : 'You receive (NGN)',
                        prefixText: '₦ ',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.swap_vert_rounded, color: AppColors.primary, size: 18),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _cryptoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) {
                        _editingCrypto = true;
                        _onCryptoChanged(v);
                      },
                      decoration: InputDecoration(
                        labelText: isBuy ? 'You receive ($_symbol)' : 'You send ($_symbol)',
                        suffixText: _symbol,
                        suffixIcon: !isBuy
                            ? TextButton(
                                onPressed: () {
                                  _cryptoController.text = Formatters.crypto(asset.balance);
                                  _editingCrypto = true;
                                  _onCryptoChanged(_cryptoController.text);
                                },
                                child: const Text('MAX'),
                              )
                            : null,
                      ),
                    ),
                    if (!isBuy) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Available: ${Formatters.crypto(asset.balance)} $_symbol',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    SummaryRow(label: 'Rate', value: '${Formatters.ngn(_rate, decimals: false)} / $_symbol'),
                    SummaryRow(
                      label: isBuy ? 'You will receive' : 'You will get paid',
                      value: isBuy
                          ? '${Formatters.crypto(cryptoAmount)} $_symbol'
                          : Formatters.ngn(ngnAmount, decimals: false),
                      valueColor: isBuy ? AppColors.success : AppColors.primary,
                    ),
                    SummaryRow(label: 'Minimum amount', value: Formatters.ngn(_minNgn, decimals: false)),
                  ],
                ),
              ),
            ),
            if (insufficientBalance) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You don\'t have enough $_symbol for this sale.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: isBuy ? 'Continue to Pay' : 'Continue to Sell',
              color: isBuy ? AppColors.success : AppColors.error,
              onPressed: (ngnAmount < _minNgn || cryptoAmount <= 0 || insufficientBalance)
                  ? null
                  : () => _continue(context, ngnAmount, cryptoAmount),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continue(BuildContext context, double ngnAmount, double cryptoAmount) async {
    final isBuy = _side == TradeSide.buy;

    if (!isBuy) {
      final confirmed = await showConfirmDialog(
        context,
        title: 'Confirm Sale',
        message:
            'Sell ${Formatters.crypto(cryptoAmount)} $_symbol to us for ${Formatters.ngn(ngnAmount, decimals: false)}? '
            'This amount will be deducted from your wallet immediately.',
        confirmLabel: 'Sell',
        confirmColor: AppColors.error,
      );
      if (!confirmed || !mounted) return;
      // Escrow the crypto immediately — mirrors how a real OTC desk would
      // lock the asset the moment an order is placed.
      context.read<WalletProvider>().adjustBalance(_symbol, -cryptoAmount);
    }

    final order = context.read<TradeProvider>().createOrder(
          side: _side,
          symbol: _symbol,
          cryptoAmount: cryptoAmount,
          fiatAmountNgn: ngnAmount,
          rateNgn: _rate,
        );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TradeOrderScreen(order: order)),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm - 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
