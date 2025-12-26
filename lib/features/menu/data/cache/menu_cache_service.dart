import 'package:qr_menu_finder/core/cache/cache_service.dart';
import '../models/menu_item_model.dart';

class MenuCacheService implements CacheService<List<MenuItemModel>> {
  final Map<String, List<MenuItemModel>> _cache = {};
  final Map<String, DateTime> _timestamps = {};
  final Duration expiry = const Duration(minutes: 30);

  @override
  Future<List<MenuItemModel>?> get(String key) async {
    final data = _cache[key];
    final ts = _timestamps[key];

    if (data == null || ts == null) return null;

    if (DateTime.now().difference(ts) >= expiry) {
      remove(key);
      return null;
    }

    return Future.value(data);
  }

  @override
  Future<void> set(String key, List<MenuItemModel> value, {Duration? ttl}) async {
    _cache[key] = value;
    _timestamps[key] = DateTime.now();
  }

  @override
  Future<void> remove(String key) async {
    _cache.remove(key);
    _timestamps.remove(key);
  }

  @override
  Future<void> clear() async {
    _cache.clear();
    _timestamps.clear();
  }
}
