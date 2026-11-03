import 'package:flutter/material.dart';
import '../../core/formatters.dart';
import '../../models/crypto_asset.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_sheets.dart';
import '../../widgets/state_views.dart';

class WithdrawScreen extends StatefulWidget {
  final CryptoAsset asset;
  const WithdrawScreen({super.key, required this.asset});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  static const _networks = ['Native Network', 'BEP-20 (BSC)', 'ERC-20 (Ethereum)'];
  String _network = _networks.first;
  bool _loading = false;

  static const _networkFee = 0.0006;

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text);
    if (_addressController.text.trim().isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid address and amount')),
      );
      return;
    }
    if (amount > widget.asset.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount exceeds available balance')),
      );
      return;
    }

    final confirmed = await showConfirmDialog(
      context,
      title: 'Confirm Withdrawal',
      message:
          'Withdraw ${Formatters.crypto(amount)} ${widget.asset.symbol} to the address entered? '
          'This action cannot be reversed.',
      confirmLabel: 'Withdraw',
      confirmColor: AppColors.primary,
    );
    if (!confirmed || !mounted) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessView(
          title: 'Withdrawal Submitted',
          message:
              'Your withdrawal of ${Formatters.crypto(amount)} ${widget.asset.symbol} is being processed.',
          onDone: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    return Scaffold(
      appBar: AppBar(title: Text('Withdraw ${asset.symbol}')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available: ${Formatters.crypto(asset.balance)} ${asset.symbol}',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _network,
                decoration: const InputDecoration(labelText: 'Network'),
                items: _networks
                    .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                    .toList(),
                onChanged: (v) => setState(() => _network = v ?? _network),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Recipient Address'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  suffixText: asset.symbol,
                  suffixIcon: TextButton(
                    onPressed: () => setState(
                      () => _amountController.text = asset.balance.toString(),
                    ),
                    child: const Text('MAX'),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      SummaryRow(label: 'Network fee', value: '$_networkFee ${asset.symbol}'),
                      SummaryRow(
                        label: 'You will receive',
                        value:
                            '${Formatters.crypto((double.tryParse(_amountController.text) ?? 0) - _networkFee)} ${asset.symbol}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(label: 'Withdraw', onPressed: _submit, loading: _loading),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
