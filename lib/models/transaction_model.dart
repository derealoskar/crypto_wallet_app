import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum TransactionType { buy, sell, swap, convert, deposit, withdrawal, airtime, data }

enum TransactionStatus { completed, pending, failed, cancelled }

extension TransactionTypeX on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.buy:
        return 'Buy';
      case TransactionType.sell:
        return 'Sell';
      case TransactionType.swap:
        return 'Swap';
      case TransactionType.convert:
        return 'Convert';
      case TransactionType.deposit:
        return 'Top Up';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.airtime:
        return 'Airtime';
      case TransactionType.data:
        return 'Data';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.buy:
        return Icons.add_circle_outline;
      case TransactionType.sell:
        return Icons.remove_circle_outline;
      case TransactionType.swap:
        return Icons.swap_horiz_rounded;
      case TransactionType.convert:
        return Icons.currency_exchange_rounded;
      case TransactionType.deposit:
        return Icons.arrow_downward_rounded;
      case TransactionType.withdrawal:
        return Icons.arrow_upward_rounded;
      case TransactionType.airtime:
        return Icons.phone_iphone_rounded;
      case TransactionType.data:
        return Icons.wifi_rounded;
    }
  }
}

extension TransactionStatusX on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.pending:
        return AppColors.warning;
      case TransactionStatus.failed:
        return AppColors.error;
      case TransactionStatus.cancelled:
        return AppColors.textMuted;
    }
  }
}

class TransactionModel {
  final String id;
  final TransactionType type;
  final String assetSymbol;
  final double amount; // in asset unit (or airtime/data value)
  final double fiatAmountNgn;
  final DateTime date;
  final TransactionStatus status;
  final String? note;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.assetSymbol,
    required this.amount,
    required this.fiatAmountNgn,
    required this.date,
    required this.status,
    this.note,
  });
}
