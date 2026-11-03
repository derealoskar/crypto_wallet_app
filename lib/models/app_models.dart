import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum NotificationCategory { transactions, trade, security, promotions }

extension NotificationCategoryX on NotificationCategory {
  String get label {
    switch (this) {
      case NotificationCategory.transactions:
        return 'Transactions';
      case NotificationCategory.trade:
        return 'Trade';
      case NotificationCategory.security:
        return 'Security';
      case NotificationCategory.promotions:
        return 'Promotions';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationCategory.transactions:
        return Icons.receipt_long_rounded;
      case NotificationCategory.trade:
        return Icons.handshake_rounded;
      case NotificationCategory.security:
        return Icons.shield_rounded;
      case NotificationCategory.promotions:
        return Icons.local_offer_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationCategory.transactions:
        return AppColors.info;
      case NotificationCategory.trade:
        return AppColors.primary;
      case NotificationCategory.security:
        return AppColors.error;
      case NotificationCategory.promotions:
        return AppColors.warning;
    }
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final DateTime date;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.date,
    this.isRead = false,
  });

  AppNotification markRead() => AppNotification(
        id: id,
        title: title,
        body: body,
        category: category,
        date: date,
        isRead: true,
      );
}

enum KycStatus { notVerified, pending, verified, rejected }

extension KycStatusX on KycStatus {
  String get label {
    switch (this) {
      case KycStatus.notVerified:
        return 'Not verified';
      case KycStatus.pending:
        return 'Pending review';
      case KycStatus.verified:
        return 'Verified';
      case KycStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case KycStatus.notVerified:
        return AppColors.textMuted;
      case KycStatus.pending:
        return AppColors.warning;
      case KycStatus.verified:
        return AppColors.success;
      case KycStatus.rejected:
        return AppColors.error;
    }
  }
}

class AppUser {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String? avatarInitials;
  final KycStatus kycStatus;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    this.avatarInitials,
    this.kycStatus = KycStatus.notVerified,
  });
}
