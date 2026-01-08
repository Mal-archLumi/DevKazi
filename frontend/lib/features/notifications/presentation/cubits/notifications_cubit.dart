// lib/features/notifications/presentation/cubits/notifications_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/notification_permission_service.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/use_cases/clear_notifications_use_case.dart';
import '../../domain/use_cases/get_notifications_use_case.dart';
import 'notifications_state.dart';
import 'package:logger/logger.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final ClearNotificationsUseCase clearNotificationsUseCase;
  final NotificationRepository repository;
  final Logger logger = Logger();

  final NotificationPermissionService _permissionService =
      NotificationPermissionService();

  NotificationsCubit({
    required this.getNotificationsUseCase,
    required this.clearNotificationsUseCase,
    required this.repository,
  }) : super(const NotificationsState());

  // Check and request notification permission
  Future<bool> checkAndRequestPermission() async {
    try {
      final isGranted = await _permissionService.isPermissionGranted();

      if (!isGranted) {
        logger.d('🔔 Notification permission not granted, requesting...');
        final granted = await _permissionService.requestPermission();

        if (granted) {
          logger.d('✅ Notification permission granted');
          // Show welcome notification
          await _permissionService.showLocalNotification(
            title: 'Welcome to DevKazi!',
            body: 'You\'ll now receive notifications for team activities.',
          );
        } else {
          logger.w('⚠️ Notification permission denied');
        }

        return granted;
      }

      return true;
    } catch (e) {
      logger.e('❌ Error checking notification permission: $e');
      return false;
    }
  }

  Future<void> loadNotifications() async {
    emit(state.copyWith(status: NotificationsStatus.loading));

    final result = await getNotificationsUseCase();

    result.fold(
      (failure) {
        logger.e('❌ Failed to load notifications: ${failure.message}');
        emit(
          state.copyWith(
            status: NotificationsStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (notifications) {
        logger.d('✅ Loaded ${notifications.length} notifications');
        final unreadCount = notifications.where((n) => !n.isRead).length;
        emit(
          state.copyWith(
            status: NotificationsStatus.success,
            notifications: notifications,
            unreadCount: unreadCount,
          ),
        );
      },
    );
  }

  Future<void> refreshUnreadCount() async {
    final result = await repository.getUnreadCount();
    result.fold(
      (failure) => logger.e('❌ Failed to get unread count: ${failure.message}'),
      (count) {
        logger.d('✅ Unread count: $count');
        emit(state.copyWith(unreadCount: count));
      },
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final result = await repository.markAsRead(notificationId);

    result.fold(
      (failure) {
        logger.e('❌ Failed to mark as read: ${failure.message}');
      },
      (_) {
        logger.d('✅ Marked notification as read: $notificationId');
        final updatedNotifications = state.notifications.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();

        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

        emit(
          state.copyWith(
            notifications: updatedNotifications,
            unreadCount: unreadCount,
          ),
        );
      },
    );
  }

  Future<void> markAllAsRead() async {
    final result = await repository.markAllAsRead();

    result.fold(
      (failure) {
        logger.e('❌ Failed to mark all as read: ${failure.message}');
      },
      (_) {
        logger.d('✅ Marked all notifications as read');
        final updatedNotifications = state.notifications.map((n) {
          return n.copyWith(isRead: true);
        }).toList();

        emit(
          state.copyWith(notifications: updatedNotifications, unreadCount: 0),
        );
      },
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    emit(
      state.copyWith(
        status: NotificationsStatus.deleting,
        deletingId: notificationId,
      ),
    );

    final result = await repository.deleteNotification(notificationId);

    result.fold(
      (failure) {
        logger.e('❌ Failed to delete notification: ${failure.message}');
        emit(
          state.copyWith(status: NotificationsStatus.success, deletingId: null),
        );
      },
      (_) {
        logger.d('✅ Deleted notification: $notificationId');
        final updatedNotifications = state.notifications
            .where((n) => n.id != notificationId)
            .toList();

        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

        emit(
          state.copyWith(
            status: NotificationsStatus.success,
            notifications: updatedNotifications,
            unreadCount: unreadCount,
            deletingId: null,
          ),
        );
      },
    );
  }

  Future<void> clearAll() async {
    final result = await clearNotificationsUseCase();

    result.fold(
      (failure) {
        logger.e('❌ Failed to clear notifications: ${failure.message}');
        emit(
          state.copyWith(
            status: NotificationsStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        logger.d('✅ Cleared all notifications');
        emit(
          state.copyWith(
            status: NotificationsStatus.success,
            notifications: [],
            unreadCount: 0,
          ),
        );
      },
    );
  }
}
