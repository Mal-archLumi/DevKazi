import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import '../../domain/use_cases/get_current_user_use_case.dart';
import '../../domain/use_cases/update_profile_use_case.dart';
import '../../domain/use_cases/logout_use_case.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final LogoutUseCase logoutUseCase;

  // Track active operations for cancellation
  Completer<void>? _currentOperation;
  bool _isDisposed = false;

  UserCubit({
    required this.getCurrentUserUseCase,
    required this.updateProfileUseCase,
    required this.logoutUseCase,
  }) : super(UserInitial());

  // Helper method to safely emit states
  void _safeEmit(UserState newState) {
    if (!_isDisposed && isClosed == false) {
      emit(newState);
    }
  }

  Future<void> loadCurrentUser({bool forceRefresh = false}) async {
    // Cancel previous operation if still running
    if (_currentOperation?.isCompleted == false) {
      _currentOperation?.complete();
    }

    _currentOperation = Completer<void>();

    // Don't emit loading if we're already loading or have data
    if (state is! UserLoading && (forceRefresh || state is! UserLoaded)) {
      _safeEmit(UserLoading());
    }

    try {
      final result = await getCurrentUserUseCase();

      // Check if operation was cancelled or cubit disposed
      if (_currentOperation?.isCompleted == true || _isDisposed) {
        return;
      }

      result.fold(
        (failure) => _safeEmit(UserError(failure.message)),
        (user) => _safeEmit(UserLoaded(user)),
      );
    } catch (error) {
      if (!_isDisposed) {
        _safeEmit(UserError('Failed to load user: $error'));
      }
    } finally {
      _currentOperation?.complete();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? bio,
    String? education,
    List<String>? skills,
    bool? isProfilePublic,
  }) async {
    final currentState = state;
    if (currentState is! UserLoaded) return;

    // Cancel previous operation
    if (_currentOperation?.isCompleted == false) {
      _currentOperation?.complete();
    }

    _currentOperation = Completer<void>();
    _safeEmit(UserLoading());

    try {
      final result = await updateProfileUseCase(
        name: name,
        bio: bio,
        education: education,
        skills: skills,
        isProfilePublic: isProfilePublic,
      );

      if (_currentOperation?.isCompleted == true || _isDisposed) {
        return;
      }

      result.fold(
        (failure) =>
            _safeEmit(UserError(failure.message, lastUser: currentState.user)),
        (user) => _safeEmit(UserLoaded(user)),
      );
    } catch (error) {
      if (!_isDisposed) {
        _safeEmit(
          UserError(
            'Failed to update profile: $error',
            lastUser: currentState.user,
          ),
        );
      }
    } finally {
      _currentOperation?.complete();
    }
  }

  Future<void> addSkills(List<String> skills) async {
    final currentState = state;
    if (currentState is! UserLoaded) return;

    if (_currentOperation?.isCompleted == false) {
      _currentOperation?.complete();
    }

    _currentOperation = Completer<void>();
    _safeEmit(UserLoading());

    try {
      final currentSkills = currentState.user.skills;
      final newSkills = [...currentSkills];
      for (final skill in skills) {
        if (!newSkills.contains(skill)) {
          newSkills.add(skill);
        }
      }

      final result = await updateProfileUseCase(skills: newSkills);

      if (_currentOperation?.isCompleted == true || _isDisposed) {
        return;
      }

      result.fold(
        (failure) =>
            _safeEmit(UserError(failure.message, lastUser: currentState.user)),
        (user) => _safeEmit(UserLoaded(user)),
      );
    } catch (error) {
      if (!_isDisposed) {
        _safeEmit(
          UserError(
            'Failed to add skills: $error',
            lastUser: currentState.user,
          ),
        );
      }
    } finally {
      _currentOperation?.complete();
    }
  }

  Future<void> removeSkill(String skill) async {
    final currentState = state;
    if (currentState is! UserLoaded) return;

    if (_currentOperation?.isCompleted == false) {
      _currentOperation?.complete();
    }

    _currentOperation = Completer<void>();
    _safeEmit(UserLoading());

    try {
      final updatedSkills = currentState.user.skills
          .where((s) => s != skill)
          .toList();
      final result = await updateProfileUseCase(skills: updatedSkills);

      if (_currentOperation?.isCompleted == true || _isDisposed) {
        return;
      }

      result.fold(
        (failure) =>
            _safeEmit(UserError(failure.message, lastUser: currentState.user)),
        (user) => _safeEmit(UserLoaded(user)),
      );
    } catch (error) {
      if (!_isDisposed) {
        _safeEmit(
          UserError(
            'Failed to remove skill: $error',
            lastUser: currentState.user,
          ),
        );
      }
    } finally {
      _currentOperation?.complete();
    }
  }

  Future<void> logout() async {
    // Cancel any pending operations
    if (_currentOperation?.isCompleted == false) {
      _currentOperation?.complete();
    }

    _currentOperation = Completer<void>();

    try {
      final result = await logoutUseCase();

      if (_currentOperation?.isCompleted == true || _isDisposed) {
        return;
      }

      result.fold(
        (failure) => _safeEmit(UserLogoutError(failure.message)),
        (_) => _safeEmit(UserLoggedOut()),
      );
    } catch (error) {
      if (!_isDisposed) {
        _safeEmit(UserLogoutError('Logout failed: $error'));
      }
    } finally {
      _currentOperation?.complete();
    }
  }

  void clearError() {
    if (_isDisposed) return;

    if (state is UserError) {
      final currentState = state as UserError;
      if (currentState.lastUser != null) {
        _safeEmit(UserLoaded(currentState.lastUser!));
      } else {
        loadCurrentUser();
      }
    } else if (state is UserLogoutError) {
      _safeEmit(UserLoggedOut());
    }
  }

  @override
  Future<void> close() {
    _isDisposed = true;
    if (_currentOperation?.isCompleted == false) {
      _currentOperation?.complete();
    }
    return super.close();
  }
}
