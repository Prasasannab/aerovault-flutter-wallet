import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../../domain/entities/app_notification.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationsBloc>(
      create: (_) => sl<NotificationsBloc>()..add(const LoadNotificationsEvent()),
      child: const _NotificationsSheetContent(),
    );
  }
}

class _NotificationsSheetContent extends StatelessWidget {
  const _NotificationsSheetContent();

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.82,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Drag Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, state) {
                  final unreadCount = (state is NotificationsLoaded) ? state.unreadCount : 0;

                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldGlow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.notifications_active_outlined, color: AppColors.emerald, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Audit & Alerts',
                                  style: AppTextStyles.heading2(color: colors.textPrimary),
                                ),
                                if (unreadCount > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.emerald,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$unreadCount NEW',
                                      style: AppTextStyles.label(
                                        color: AppColors.background,
                                        fontSize: 9.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'FINMA AUDIT & TELEMETRY STREAM',
                              style: AppTextStyles.label(color: colors.textMuted, fontSize: 9.5),
                            ),
                          ],
                        ),
                      ),
                      if (unreadCount > 0)
                        BounceButton(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.read<NotificationsBloc>().add(const MarkAllNotificationsAsReadEvent());
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: colors.border),
                            ),
                            child: Text(
                              'Mark All Read',
                              style: AppTextStyles.label(color: AppColors.emerald, fontSize: 10.5),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Category Filter Pills
            BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, state) {
                final selectedCategory =
                    (state is NotificationsLoaded) ? state.selectedCategory : null;

                return SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildFilterChip(
                        context,
                        colors,
                        label: 'All',
                        isSelected: selectedCategory == null,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.read<NotificationsBloc>().add(const FilterNotificationsCategoryEvent(null));
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        colors,
                        label: 'Security',
                        icon: Icons.shield_outlined,
                        isSelected: selectedCategory == NotificationCategory.security,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.read<NotificationsBloc>().add(const FilterNotificationsCategoryEvent(NotificationCategory.security));
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        colors,
                        label: 'Transfers',
                        icon: Icons.swap_horiz_rounded,
                        isSelected: selectedCategory == NotificationCategory.transfer,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.read<NotificationsBloc>().add(const FilterNotificationsCategoryEvent(NotificationCategory.transfer));
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        colors,
                        label: 'Compliance',
                        icon: Icons.verified_outlined,
                        isSelected: selectedCategory == NotificationCategory.compliance,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.read<NotificationsBloc>().add(const FilterNotificationsCategoryEvent(NotificationCategory.compliance));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            Divider(height: 1, color: colors.border),

            // Notification List
            Expanded(
              child: BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, state) {
                  if (state is NotificationsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.emerald),
                    );
                  }

                  if (state is NotificationsError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: AppTextStyles.bodyMedium(color: AppColors.error),
                      ),
                    );
                  }

                  if (state is NotificationsLoaded) {
                    final items = state.filteredNotifications;

                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline_rounded, color: colors.textMuted, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              'All Telemetry Clear',
                              style: AppTextStyles.heading3(color: colors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No pending alerts for this category',
                              style: AppTextStyles.bodySmall(color: colors.textMuted),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final notification = items[index];
                        return _buildNotificationCard(context, colors, notification);
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),

            // Bank-Grade Security Footer Note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_clock_outlined, size: 14, color: AppColors.emerald),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'End-to-End Encrypted Telemetry • Stamped via Secure Enclave',
                      style: AppTextStyles.bodySmall(color: colors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    AeroVaultColors colors, {
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return BounceButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.emerald : colors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.emerald : colors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? AppColors.background : colors.textSecondary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: AppTextStyles.label(
                color: isSelected ? AppColors.background : colors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AeroVaultColors colors,
    AppNotification notification,
  ) {
    Color accentColor;
    IconData icon;

    switch (notification.category) {
      case NotificationCategory.security:
        accentColor = notification.priority == NotificationPriority.critical
            ? const Color(0xFFEF4444)
            : AppColors.cyan;
        icon = Icons.security_rounded;
        break;
      case NotificationCategory.transfer:
        accentColor = AppColors.emerald;
        icon = Icons.account_balance_wallet_rounded;
        break;
      case NotificationCategory.compliance:
        accentColor = AppColors.violet;
        icon = Icons.verified_user_rounded;
        break;
      case NotificationCategory.system:
        accentColor = colors.textSecondary;
        icon = Icons.info_outline_rounded;
        break;
    }

    return BounceButton(
      onTap: () {
        HapticFeedback.lightImpact();
        if (!notification.isRead) {
          context.read<NotificationsBloc>().add(MarkNotificationAsReadEvent(notification.id));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead ? colors.surface : colors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? colors.border
                : accentColor.withValues(alpha: 0.35),
            width: notification.isRead ? 1.0 : 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon Badge
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.bodyMedium(
                            color: colors.textPrimary,
                          ).copyWith(
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: AppTextStyles.bodySmall(color: colors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: AppTextStyles.bodySmall(
                      color: notification.isRead ? colors.textMuted : colors.textSecondary,
                    ),
                  ),
                  if (notification.referenceCode != null || notification.amountFormatted != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (notification.referenceCode != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: colors.border),
                            ),
                            child: Text(
                              notification.referenceCode!,
                              style: AppTextStyles.monospace(
                                color: colors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (notification.amountFormatted != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            notification.amountFormatted!,
                            style: AppTextStyles.monospace(
                              color: AppColors.emerald,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (!notification.isRead)
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
