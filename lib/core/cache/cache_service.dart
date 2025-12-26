abstract class CacheService<T> {
  Future<T?> get(String key);
  Future<void> set(String key, T value, {Duration? ttl});
  Future<void> remove(String key);
  Future<void> clear();
}
