import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import '../repositories/user_repository.dart';

class UpdateProfileUseCase {
  final UserRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    String? name,
    String? bio,
    String? education,
    List<String>? skills,
    bool? isProfilePublic,
  }) async {
    return await repository.updateProfile(
      name: name,
      bio: bio,
      education: education,
      skills: skills,
      isProfilePublic: isProfilePublic,
    );
  }
}
