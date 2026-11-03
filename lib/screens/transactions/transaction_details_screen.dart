import 'package:flutter/material.dart';
import '../../core/formatters.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/state_views.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: t.status.color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(t.type.icon, size: 32, color: t.status.color),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('${t.type.label} ${t.assetSymbol}', style: AppTextStyles.headingMedium),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: t.status.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  t.status.label,
                  style: AppTextStyles.bodySmall.copyWith(color: t.status.color, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      SummaryRow(label: 'Amount', value: '${Formatters.crypto(t.amount)} ${t.assetSymbol}'),
                      SummaryRow(label: 'Fiat value', value: Formatters.ngn(t.fiatAmountNgn)),
                      SummaryRow(label: 'Date', value: Formatters.fullDate(t.date)),
                      SummaryRow(label: 'Reference', value: '#${t.id.toUpperCase()}'),
                      if (t.note != null) SummaryRow(label: 'Details', value: t.note!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: SecondaryButton(
                  label: 'Share Receipt',
                  icon: Icons.ios_share_rounded,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
