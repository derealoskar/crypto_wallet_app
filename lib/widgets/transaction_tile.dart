import 'package:flutter/material.dart';
import '../core/formatters.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  bool get _isCredit =>
      transaction.type == TransactionType.sell ||
      transaction.type == TransactionType.deposit;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: t.status.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(t.type.icon, color: t.status.color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${t.type.label} ${t.assetSymbol}', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 2),
                  Text(Formatters.date(t.date), style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_isCredit ? '+' : '-'}${Formatters.ngn(t.fiatAmountNgn)}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: _isCredit ? AppColors.success : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.status.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: t.status.color,
                    fontWeight: FontWeight.w600,
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
