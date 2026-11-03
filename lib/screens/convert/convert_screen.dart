import 'package:flutter/material.dart';
import '../../core/formatters.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_sheets.dart';
import '../../widgets/state_views.dart';

class ConvertScreen extends StatefulWidget {
  const ConvertScreen({super.key});

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  static const _currencies = {
    'NGN': 1.0,
    'USD': 1550.0,
    'EUR': 1680.0,
    'GBP': 1970.0,
    'USDT': 1552.0,
    'BTC': 98450000.0,
    'ETH': 5320000.0,
    'USDC': 1550.0,
  };

  String _from = 'NGN';
  String _to = 'USDT';
  final _amountController = TextEditingController(text: '100000');
  bool _loading = false;

  double get _amount => double.tryParse(_amountController.text) ?? 0;

  double get _result {
    final fromRateNgn = _currencies[_from]!;
    final toRateNgn = _currencies[_to]!;
    final ngnValue = _amount * fromRateNgn;
    final feeAdjusted = ngnValue * 0.995; // 0.5% conversion fee
    return feeAdjusted / toRateNgn;
  }

  double get _feeNgn => (_amount * _currencies[_from]!) * 0.005;

  void _flip() {
    setState(() {
      final tmp = _from;
      _from = _to;
      _to = tmp;
    });
  }

  Future<void> _pickCurrency({required bool isFrom}) async {
    final selected = await showAppBottomSheet<String>(
      context: context,
      title: 'Select currency',
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final c in _currencies.keys)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                child: Text(c.characters.first),
              ),
              title: Text(c),
              onTap: () => Navigator.pop(context, c),
            ),
        ],
      ),
    );
    if (selected == null) return;
    setState(() {
      if (isFrom) {
        _from = selected;
      } else {
        _to = selected;
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              _CurrencyInputCard(
                label: 'You convert',
                currency: _from,
                controller: _amountController,
                editable: true,
                onCurrencyTap: () => _pickCurrency(isFrom: true),
              ),
              Center(
                child: InkWell(
                  onTap: _flip,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.swap_vert_rounded, color: AppColors.primary),
                  ),
                ),
              ),
              _CurrencyInputCard(
                label: 'You receive',
                currency: _to,
                displayValue: Formatters.crypto(_result, decimals: 8),
                editable: false,
                onCurrencyTap: () => _pickCurrency(isFrom: false),
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      SummaryRow(
                        label: 'Rate',
                        value: '1 $_from ≈ ${Formatters.crypto(_currencies[_from]! / _currencies[_to]!, decimals: 8)} $_to',
                      ),
                      SummaryRow(label: 'Conversion fee', value: '${Formatters.ngn(_feeNgn, decimals: false)} (0.5%)'),
                      SummaryRow(
                        label: 'Amount received',
                        value: '${Formatters.crypto(_result, decimals: 8)} $_to',
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
                  label: 'Convert Now',
                  loading: _loading,
                  onPressed: _amount <= 0 ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessView(
          title: 'Conversion Complete',
          message:
              'Converted ${Formatters.plain(_amount)} $_from to ${Formatters.crypto(_result, decimals: 6)} $_to.',
          onDone: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ),
    );
  }
}

class _CurrencyInputCard extends StatelessWidget {
  final String label;
  final String currency;
  final TextEditingController? controller;
  final String? displayValue;
  final bool editable;
  final VoidCallback onCurrencyTap;

  const _CurrencyInputCard({
    required this.label,
    required this.currency,
    this.controller,
    this.displayValue,
    required this.editable,
    required this.onCurrencyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: editable
                      ? TextField(
                          controller: controller,
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
                  onTap: onCurrencyTap,
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
                        Text(currency, style: AppTextStyles.bodyLarge),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
