import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_sheets.dart';
import '../../widgets/state_views.dart';

class AirtimeScreen extends StatefulWidget {
  const AirtimeScreen({super.key});

  @override
  State<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends State<AirtimeScreen> {
  String _network = MockDataService.networks.first;
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  String _paymentMethod = 'USDT Wallet';
  bool _loading = false;

  static const _quickAmounts = [100.0, 200.0, 500.0, 1000.0, 2000.0, 5000.0];
  static const _feeFraction = 0.0; // Nigerian airtime purchases are typically fee-free

  double get _amount => double.tryParse(_amountController.text) ?? 0;
  double get _fee => _amount * _feeFraction;
  double get _total => _amount + _fee;

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_phoneController.text.trim().length < 10 || _amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number and amount')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);

    context.read<TransactionProvider>().addTransaction(
          TransactionModel(
            id: 'air-${DateTime.now().millisecondsSinceEpoch}',
            type: TransactionType.airtime,
            assetSymbol: 'NGN',
            amount: _amount,
            fiatAmountNgn: _total,
            date: DateTime.now(),
            status: TransactionStatus.completed,
            note: '$_network · ${_phoneController.text}',
          ),
        );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessView(
          title: 'Airtime Purchased',
          message: '${Formatters.ngn(_amount)} $_network airtime was sent to ${_phoneController.text}.',
          onDone: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buy Airtime')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Network', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final n in MockDataService.networks) ...[
                    Expanded(
                      child: _NetworkChip(
                        label: n,
                        selected: _network == n,
                        onTap: () => setState(() => _network = n),
                      ),
                    ),
                    if (n != MockDataService.networks.last) const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number', hintText: '0803 456 7890'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '₦ '),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in _quickAmounts)
                    _AmountChip(
                      amount: a,
                      onTap: () => setState(() => _amountController.text = a.toStringAsFixed(0)),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment method'),
                items: const ['USDT Wallet', 'BTC Wallet', 'Naira Balance']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _paymentMethod = v ?? _paymentMethod),
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      SummaryRow(label: 'Service fee', value: Formatters.ngn(_fee)),
                      SummaryRow(label: 'Total', value: Formatters.ngn(_total), valueColor: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(label: 'Buy Airtime', onPressed: _submit, loading: _loading),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NetworkChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  final double amount;
  final VoidCallback onTap;

  const _AmountChip({required this.amount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(Formatters.ngn(amount, decimals: false), style: AppTextStyles.bodySmall),
      ),
    );
  }
}
