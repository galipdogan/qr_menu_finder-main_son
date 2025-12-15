import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Abstract local data source
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
}

/// Implementation with SharedPreferences
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  static const cachedUserKey = 'CACHED_USER';

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await sharedPreferences.setString(cachedUserKey, user.toJsonString());
    } catch (e) {
      // Burada loglama yapabilirsin
      print('Failed to cache user: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(cachedUserKey);
      if (jsonString != null) {
        return UserModel.fromJsonString(jsonString);
      }
    } catch (e) {
      print('Failed to get cached user: $e');
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(cachedUserKey);
  }
}
