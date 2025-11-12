import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class UserLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUserData();
  Future<void> clearAllData();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const String _userKey = 'cached_user';

  UserLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheUser(UserModel user) async {
    // For now, we'll store basic user info
    // In production, consider using a proper database like Hive or SQLite
    final userData = {
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'skills': user.skills.join(','),
      'bio': user.bio ?? '',
      'education': user.education ?? '',
      'avatar': user.avatar ?? '',
      'isVerified': user.isVerified.toString(),
      'isProfilePublic': user.isProfilePublic.toString(),
    };

    // Store as string (simplified approach)
    await secureStorage.write(key: _userKey, value: userData.toString());
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userData = await secureStorage.read(key: _userKey);
      if (userData == null) return null;

      // This is a simplified approach - in production use proper serialization
      // For now, return null to force fresh API call
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearUserData() async {
    await secureStorage.delete(key: _userKey);
  }

  @override
  Future<void> clearAllData() async {
    await secureStorage.deleteAll();
  }
}
