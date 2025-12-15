import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Cache manager for clean architecture
class CacheManager {
  static const String _keyPrefix = 'qr_menu_finder_';
  static const Duration _defaultTtl = Duration(hours: 1);
  
  final SharedPreferences _prefs;
  
  CacheManager(this._prefs);
  
  /// Cache data with TTL
  Future<void> cacheData<T>({
    required String key,
    required T data,
    Duration? ttl,
  }) async {
    try {
      final cacheKey = _keyPrefix + key;
      final expiryTime = DateTime.now().add(ttl ?? _defaultTtl);
      
      final cacheItem = {
        'data': data,
        'expiry': expiryTime.millisecondsSinceEpoch,
      };
      
      await _prefs.setString(cacheKey, jsonEncode(cacheItem));
      AppLogger.d('Cached data for key: $key');
    } catch (e) {
      AppLogger.e('Failed to cache data for key: $key', error: e);
    }
  }
  
  /// Get cached data
  T? getCachedData<T>(String key) {
    try {
      final cacheKey = _keyPrefix + key;
      final cachedString = _prefs.getString(cacheKey);
      
      if (cachedString == null) {
        AppLogger.d('No cached data for key: $key');
        return null;
      }
      
      final cacheItem = jsonDecode(cachedString) as Map<String, dynamic>;
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(cacheItem['expiry']);
      
      if (DateTime.now().isAfter(expiryTime)) {
        AppLogger.d('Cached data expired for key: $key');
        _prefs.remove(cacheKey);
        return null;
      }
      
      AppLogger.d('Retrieved cached data for key: $key');
      return cacheItem['data'] as T;
    } catch (e) {
      AppLogger.e('Failed to get cached data for key: $key', error: e);
      return null;
    }
  }
  
  /// Check if data is cached and valid
  bool isCached(String key) {
    return getCachedData(key) != null;
  }
  
  /// Clear specific cache
  Future<void> clearCache(String key) async {
    try {
      final cacheKey = _keyPrefix + key;
      await _prefs.remove(cacheKey);
      AppLogger.d('Cleared cache for key: $key');
    } catch (e) {
      AppLogger.e('Failed to clear cache for key: $key', error: e);
    }
  }
  
  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      final keys = _prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      for (final key in keys) {
        await _prefs.remove(key);
      }
      AppLogger.d('Cleared all cache');
    } catch (e) {
      AppLogger.e('Failed to clear all cache', error: e);
    }
  }
  
  /// Get cache size (approximate)
  int getCacheSize() {
    try {
      final keys = _prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      return keys.length;
    } catch (e) {
      AppLogger.e('Failed to get cache size', error: e);
      return 0;
    }
  }
}