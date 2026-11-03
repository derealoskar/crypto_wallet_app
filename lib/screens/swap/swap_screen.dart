import 'package:flutter/material.dart';
import 'package:characters/characters.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_sheets.dart';
import '../../widgets/state_views.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({super.key});

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  String _fromSymbol = 'USDT';
  String _toSymbol = 'BTC';
  final _amountController = TextEditingController(text: '100');
  static const _slippage = 0.5; // percent
  bool _loading = false;

  void _flip() {
    setState(() {
      final tmp = _fromSymbol;
      _fromSymbol = _toSymbol;
      _toSymbol = tmp;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final from = wallet.assetBySymbol(_fromSymbol);
    final to = wallet.assetBySymbol(_toSymbol);
    final amount = double.tryParse(_amountController.text) ?? 0;
    final rate = from.priceNgn / to.priceNgn;
    const networkFeeNgn = 350.0;
    final receiveAmount = amount > 0 ? (amount * rate) - (networkFeeNgn / to.priceNgn) : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Swap')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _SwapTokenRow(
                        label: 'From',
                        symbol: _fromSymbol,
                        amountController: _amountController,
                        editable: true,
                        balance: from.balance,
                        onSymbolTap: () => _pickAsset(context, isFrom: true),
                      ),
                      Center(
                        child: InkWell(
                          onTap: _flip,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.swap_vert_rounded, color: AppColors.primary),
                          ),
                        ),
                      ),
                      _SwapTokenRow(
                        label: 'To',
                        symbol: _toSymbol,
                        editable: false,
                        displayValue: Formatters.crypto(receiveAmount < 0 ? 0 : receiveAmount),
                        balance: to.balance,
                        onSymbolTap: () => _pickAsset(context, isFrom: false),
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
                      SummaryRow(
                        label: 'Exchange rate',
                        value: '1 $_fromSymbol ≈ ${Formatters.crypto(rate)} $_toSymbol',
                      ),
                      SummaryRow(label: 'Network fee', value: Formatters.ngn(networkFeeNgn)),
                      const SummaryRow(label: 'Slippage tolerance', value: '$_slippage%'),
                      SummaryRow(
                        label: 'Estimated received',
                        value: '${Formatters.crypto(receiveAmount < 0 ? 0 : receiveAmount)} $_toSymbol',
                        valueColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Confirm Swap',
                  loading: _loading,
                  onPressed: amount <= 0 || amount > from.balance
                      ? null
                      : () => _confirmSwap(context, amount, receiveAmount),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAsset(BuildContext context, {required bool isFrom}) async {
    final wallet = context.read<WalletProvider>();
    final selected = await showAppBottomSheet<String>(
      context: context,
      title: 'Select a token',
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final a in wallet.assets)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: a.accentColor.withValues(alpha: 0.14),
                child: Text(a.symbol.characters.first),
              ),
              title: Text(a.name),
              subtitle: Text(a.symbol),
              onTap: () => Navigator.pop(context, a.symbol),
            ),
        ],
      ),
    );
    if (selected == null) return;
    setState(() {
      if (isFrom) {
        _fromSymbol = selected;
      } else {
        _toSymbol = selected;
      }
    });
  }

  Future<void> _confirmSwap(BuildContext context, double amount, double receiveAmount) async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);

    context.read<TransactionProvider>().addTransaction(
          TransactionModel(
            id: 'swap-${DateTime.now().millisecondsSinceEpoch}',
            type: TransactionType.swap,
            assetSymbol: _toSymbol,
            amount: receiveAmount,
            fiatAmountNgn: amount * context.read<WalletProvider>().assetBySymbol(_fromSymbol).priceNgn,
            date: DateTime.now(),
            status: TransactionStatus.completed,
            note: 'Swapped from $_fromSymbol',
          ),
        );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessView(
          title: 'Swap Completed',
          message:
              'You swapped ${Formatters.crypto(amount)} $_fromSymbol for ${Formatters.crypto(receiveAmount)} $_toSymbol.',
          onDone: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ),
    );
  }
}

class _SwapTokenRow extends StatelessWidget {
  final String label;
  final String symbol;
  final TextEditingController? amountController;
  final String? displayValue;
  final bool editable;
  final double balance;
  final VoidCallback onSymbolTap;

  const _SwapTokenRow({
    required this.label,
    required this.symbol,
    this.amountController,
    this.displayValue,
    required this.editable,
    required this.balance,
    required this.onSymbolTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: editable
                  ? TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: AppTextStyles.headingMedium,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                    )
                  : Text(displayValue ?? '0', style: AppTextStyles.headingMedium),
            ),
            InkWell(
              onTap: onSymbolTap,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(symbol, style: AppTextStyles.bodyLarge),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Balance: ${Formatters.crypto(balance)} $symbol', style: AppTextStyles.caption),
      ],
    );
  }
}
