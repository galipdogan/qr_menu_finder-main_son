import 'package:qr_menu_finder/core/cache/cache_service.dart';
import '../models/menu_item_model.dart';

class MenuCacheService implements CacheService<List<MenuItemModel>> {
  final Map<String, List<MenuItemModel>> _cache = {};
  final Map<String, DateTime> _timestamps = {};
  final Duration expiry = const Duration(minutes: 30);

  @override
  List<MenuItemModel>? get(String key) {
    final data = _cache[key];
    final ts = _timestamps[key];

    if (data == null || ts == null) return null;

    if (DateTime.now().difference(ts) >= expiry) {
      remove(key);
      return null;
    }

    return data;
  }

  @override
  void set(String key, List<MenuItemModel> value) {
    _cache[key] = value;
    _timestamps[key] = DateTime.now();
  }

  @override
  void remove(String key) {
    _cache.remove(key);
    _timestamps.remove(key);
  }

  @override
  void clear() {
    _cache.clear();
    _timestamps.clear();
  }
}
