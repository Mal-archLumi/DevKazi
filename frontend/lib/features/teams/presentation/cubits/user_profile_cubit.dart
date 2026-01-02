// features/user/presentation/cubits/user_profile_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';

enum UserProfileStatus { initial, loading, loaded, error }

class UserProfileState {
  final UserProfileStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const UserProfileState({required this.status, this.user, this.errorMessage});

  UserProfileState copyWith({
    UserProfileStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit()
    : super(UserProfileState(status: UserProfileStatus.initial));

  void loadUserProfile(String userId) {
    emit(state.copyWith(status: UserProfileStatus.loading));

    // TODO: Implement actual user profile loading
    // For now, emit a placeholder state with all required fields
    emit(
      state.copyWith(
        status: UserProfileStatus.loaded,
        user: UserEntity(
          id: userId,
          email: 'user@example.com',
          name: 'User Name',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          accessToken: 'placeholder_token',
          refreshToken: 'placeholder_refresh_token',
          skills: ['Flutter', 'Dart', 'Firebase'],
          bio: 'This is a sample bio for the user profile.',
          education: 'Sample University',
          avatar: null,
          isVerified: false,
          isProfilePublic: true,
          isActive: true,
        ),
      ),
    );
  }
}
