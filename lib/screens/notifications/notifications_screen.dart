import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/formatters.dart';
import '../../models/app_models.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/state_views.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final items = provider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: provider.unreadCount == 0 ? null : provider.markAllRead,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: SafeArea(
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
                  for (final c in NotificationCategory.values) ...[
                    FilterPill(
                      label: c.label,
                      selected: provider.filter == c,
                      onTap: () => provider.setFilter(c),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: EmptyStateView(
                        icon: Icons.notifications_off_rounded,
                        title: 'No notifications',
                        message: 'You\'re all caught up.',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final n = items[i];
                        return InkWell(
                          onTap: () => provider.markAsRead(n.id),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: n.category.color.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Icon(n.category.icon, color: n.category.color, size: 20),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(n.title, style: AppTextStyles.bodyLarge),
                                      const SizedBox(height: 2),
                                      Text(n.body, style: AppTextStyles.bodySmall),
                                      const SizedBox(height: 4),
                                      Text(Formatters.date(n.date), style: AppTextStyles.caption),
                                    ],
                                  ),
                                ),
                                if (!n.isRead)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
