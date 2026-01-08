// lib/features/notifications/domain/use_cases/clear_notifications_use_case.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

class ClearNotificationsUseCase {
  final NotificationRepository repository;

  ClearNotificationsUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.clearAll();
  }
}
