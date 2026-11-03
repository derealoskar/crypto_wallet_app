import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/state_views.dart';
import '../../widgets/transaction_tile.dart';
import 'transaction_details_screen.dart';

class TransactionsScreen extends StatelessWidget {
  final bool embedded;
  const TransactionsScreen({super.key, this.embedded = false});

  /// Buckets already-sorted (newest first) transactions under "Today",
  /// "Yesterday", then full dates — insertion order is preserved, so the
  /// resulting sections come out newest-first automatically.
  Map<String, List<TransactionModel>> _groupByDate(List<TransactionModel> txns) {
    final map = <String, List<TransactionModel>>{};
    for (final t in txns) {
      map.putIfAbsent(Formatters.dayHeading(t.date), () => []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final txns = provider.filtered;
    final grouped = _groupByDate(txns);

    final body = SafeArea(
      top: false,
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                FilterPill(
                  label: 'All',
                  selected: provider.filter == null,
                  onTap: () => provider.setFilter(null),
                ),
                const SizedBox(width: 8),
                for (final type in TransactionType.values) ...[
                  FilterPill(
                    label: type.label,
                    selected: provider.filter == type,
                    onTap: () => provider.setFilter(type),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: txns.isEmpty
                ? const Center(
                    child: EmptyStateView(
                      icon: Icons.receipt_long_rounded,
                      title: 'No transactions',
                      message: 'Nothing matches this filter yet.',
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
                    children: [
                      for (final entry in grouped.entries) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, AppSpacing.sm, 4, 6),
                          child: Text(
                            entry.key.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                            child: Column(
                              children: [
                                for (int i = 0; i < entry.value.length; i++) ...[
                                  TransactionTile(
                                    transaction: entry.value[i],
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            TransactionDetailsScreen(transaction: entry.value[i]),
                                      ),
                                    ),
                                  ),
                                  if (i != entry.value.length - 1) const Divider(height: 1, indent: 58),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );

    if (embedded) return body;

    return Scaffold(
      appBar: const MainAppBar(title: 'Transactions'),
      body: body,
    );
  }
}
