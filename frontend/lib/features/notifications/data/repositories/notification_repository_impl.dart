// lib/features/notifications/data/repositories/notification_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/core/network/network_info.dart';
import 'package:frontend/features/notifications/data/data_sources/notification_remote_data_source.dart';
import 'package:frontend/features/notifications/domain/entities/notification_entity.dart';
import 'package:frontend/features/notifications/domain/repositories/notification_repository.dart';
import 'package:logger/logger.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final Logger logger = Logger();

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int limit = 50,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final notifications = await remoteDataSource.getNotifications(
        limit: limit,
      );
      final entities = notifications.map((model) => model.toEntity()).toList();
      logger.d('✅ Loaded ${entities.length} notifications');
      return Right(entities);
    } catch (e) {
      logger.e('❌ Error getting notifications: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final count = await remoteDataSource.getUnreadCount();
      logger.d('✅ Unread count: $count');
      return Right(count);
    } catch (e) {
      logger.e('❌ Error getting unread count: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await remoteDataSource.markAsRead(notificationId);
      logger.d('✅ Marked notification as read: $notificationId');
      return const Right(null);
    } catch (e) {
      logger.e('❌ Error marking notification as read: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await remoteDataSource.markAllAsRead();
      logger.d('✅ Marked all notifications as read');
      return const Right(null);
    } catch (e) {
      logger.e('❌ Error marking all as read: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(
    String notificationId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await remoteDataSource.deleteNotification(notificationId);
      logger.d('✅ Deleted notification: $notificationId');
      return const Right(null);
    } catch (e) {
      logger.e('❌ Error deleting notification: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearAll() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await remoteDataSource.clearAll();
      logger.d('✅ Cleared all notifications');
      return const Right(null);
    } catch (e) {
      logger.e('❌ Error clearing notifications: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
