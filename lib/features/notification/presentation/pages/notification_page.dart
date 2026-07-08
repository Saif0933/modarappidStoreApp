import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/empty_widget.dart';

// Notification Model
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final IconData icon;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    required this.icon,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      time: time,
      isRead: isRead ?? this.isRead,
      icon: icon,
    );
  }
}

// Notifications Notifier
class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super([
    AppNotification(
      id: 'n1',
      title: 'Order Delivered Successfully!',
      body: 'Your order ORD-87123 was successfully delivered to your default address. Rate your experience now.',
      time: '2 hours ago',
      icon: Icons.local_shipping_rounded,
    ),
    AppNotification(
      id: 'n2',
      title: 'Mega Discount Inside!',
      body: 'Get up to 20% off on all winter jackets & hoodies today. Use promo coupon code "SAVE20" at checkout.',
      time: '1 day ago',
      icon: Icons.percent_rounded,
    ),
    AppNotification(
      id: 'n3',
      title: 'Welcome to ModarApp Store!',
      body: 'Complete your profile details to unlock premium member benefits and customized recommended deals.',
      time: '3 days ago',
      icon: Icons.waving_hand_rounded,
      isRead: true,
    ),
  ]);

  void markAsRead(String id) {
    state = state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void clearAll() {
    state = [];
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier();
});

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final notifications = ref.watch(notificationsProvider);

    if (notifications.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        appBar: const CustomAppBar(title: 'Notifications'),
        body: const EmptyWidget(
          icon: Icons.notifications_off_outlined,
          title: 'All Caught Up!',
          description: 'No new notifications available right now. We\'ll let you know when something comes up.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Mark all read', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM, vertical: AppConstants.spaceS),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return GestureDetector(
                    onTap: () {
                      ref.read(notificationsProvider.notifier).markAsRead(notif.id);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notif.isRead
                            ? (isDark ? AppColors.surfaceDark : Colors.white)
                            : (isDark 
                                ? AppColors.primary.withOpacity(0.08) 
                                : AppColors.primary.withOpacity(0.04)),
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                          color: notif.isRead
                              ? (isDark ? AppColors.borderDark : AppColors.borderLight)
                              : AppColors.primary.withOpacity(0.3),
                        ),
                        boxShadow: AppConstants.lowShadow,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Custom Icon Indicator with pulse dot
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark 
                                      ? AppColors.bgDark 
                                      : AppColors.primary.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  notif.icon,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              if (!notif.isRead)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),

                          // Text block details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif.title,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      notif.time,
                                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  notif.body,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Action bar to clear notifications
            Padding(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              child: TextButton.icon(
                icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
                label: const Text('Clear All Notifications', style: TextStyle(color: AppColors.error)),
                onPressed: () {
                  ref.read(notificationsProvider.notifier).clearAll();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cleared all notifications.'),
                      behavior: SnackBarBehavior.floating,
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
