import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable AppBar for the main bottom-nav sections. Pass [greeting] on the
/// Home screen only; other screens pass a plain [title].
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? greeting;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onAvatarTap;
  final List<Widget> actions;

  const MainAppBar({
    super.key,
    this.title,
    this.greeting,
    this.onNotificationsTap,
    this.onAvatarTap,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationProvider>().unreadCount;
    final user = context.watch<UserProvider>().user;

    return AppBar(
      titleSpacing: 20,
      toolbarHeight: 64,
      title: greeting != null
          ? Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Hi, $greeting 👋', style: AppTextStyles.headingSmall),
                      Text('Welcome back', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            )
          : Text(title ?? '', style: AppTextStyles.headingSmall),
      actions: [
        ...actions,
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: onNotificationsTap,
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            if (unread > 0)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
        GestureDetector(
          onTap: onAvatarTap,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                user.avatarInitials ?? '?',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
