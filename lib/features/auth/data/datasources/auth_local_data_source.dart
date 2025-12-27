import 'package:qr_menu_finder/core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/error.dart';
import '../models/user_model.dart';

/// Abstract local data source for authentication
/// 
/// Provides caching mechanism for user data
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
}

/// Implementation with SharedPreferences
/// 
/// Handles local persistence of user data with proper error handling
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  static const cachedUserKey = 'CACHED_USER';

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final success = await sharedPreferences.setString(
        cachedUserKey,
        user.toJsonString(),
      );
      if (!success) {
        throw const CacheException('Failed to cache user data');
      }
    } catch (e) {
      AppLogger.e('Failed to cache user', error: e);
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(cachedUserKey);
      if (jsonString == null) return null;
      
      return UserModel.fromJsonString(jsonString);
    } catch (e) {
      AppLogger.e('Failed to get cached user', error: e);
      // Return null instead of throwing - cache miss is not critical
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final success = await sharedPreferences.remove(cachedUserKey);
      if (!success) {
        AppLogger.w('Failed to clear cache - key may not exist');
      }
    } catch (e) {
      AppLogger.e('Failed to clear cache', error: e);
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }
}
