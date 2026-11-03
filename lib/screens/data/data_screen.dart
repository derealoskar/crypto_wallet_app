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

/// Guides the user through: 1) network 2) phone number 3) data plan
/// 4) review 5) pay 6) success — all on one scrollable screen so nothing
/// feels like separate hidden pages, with a sticky bottom action button.
class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  String _network = MockDataService.networks.first;
  final _phoneController = TextEditingController();
  Map<String, Object>? _selectedPlan;
  bool _reviewing = false;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _canReview => _phoneController.text.trim().length >= 10 && _selectedPlan != null;

  Future<void> _pay() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);

    final plan = _selectedPlan!;
    final price = plan['price'] as double;

    context.read<TransactionProvider>().addTransaction(
          TransactionModel(
            id: 'data-${DateTime.now().millisecondsSinceEpoch}',
            type: TransactionType.data,
            assetSymbol: 'NGN',
            amount: price,
            fiatAmountNgn: price,
            date: DateTime.now(),
            status: TransactionStatus.completed,
            note: '$_network · ${plan['size']} · ${_phoneController.text}',
          ),
        );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessView(
          title: 'Data Purchased',
          message: '${plan['size']} ($_network) was sent to ${_phoneController.text}.',
          onDone: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Data'),
        leading: _reviewing
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _reviewing = false),
              )
            : null,
      ),
      body: SafeArea(
        child: _reviewing ? _buildReview() : _buildSelection(),
      ),
    );
  }

  Widget _buildSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('1. Select Network', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final n in MockDataService.networks) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _network = n),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _network == n ? AppColors.primary : AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: _network == n ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(
                        n,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _network == n ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                if (n != MockDataService.networks.last) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('2. Phone Number', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: '0803 456 7890'),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('3. Select Data Plan', style: AppTextStyles.label),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: MockDataService.dataPlans.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, i) {
              final plan = MockDataService.dataPlans[i];
              final selected = _selectedPlan == plan;
              return GestureDetector(
                onTap: () => setState(() => _selectedPlan = plan),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary.withValues(alpha: 0.10) : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(plan['size'] as String, style: AppTextStyles.headingSmall),
                      const SizedBox(height: 4),
                      Text('${plan['validity']}', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.ngn(plan['price'] as double, decimals: false),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Review Order',
              onPressed: _canReview ? () => setState(() => _reviewing = true) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReview() {
    final plan = _selectedPlan!;
    final price = plan['price'] as double;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  SummaryRow(label: 'Network', value: _network),
                  SummaryRow(label: 'Phone number', value: _phoneController.text),
                  SummaryRow(label: 'Plan', value: '${plan['size']} (${plan['validity']})'),
                  SummaryRow(label: 'Amount', value: Formatters.ngn(price, decimals: false)),
                  const SummaryRow(label: 'Payment method', value: 'USDT Wallet'),
                  SummaryRow(
                    label: 'Total',
                    value: Formatters.ngn(price, decimals: false),
                    valueColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(label: 'Pay & Confirm', onPressed: _pay, loading: _loading),
          ),
        ],
      ),
    );
  }
}
