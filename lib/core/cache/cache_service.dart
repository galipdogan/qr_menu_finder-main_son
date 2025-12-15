abstract class CacheService<T> {
  T? get(String key);
  void set(String key, T value);
  void remove(String key);
  void clear();
}
