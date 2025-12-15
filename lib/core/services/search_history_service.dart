import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing search history
class SearchHistoryService {
  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 10;

  /// Get search history
  Future<List<String>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_searchHistoryKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Add search query to history
  Future<void> addToHistory(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getSearchHistory();

      // Remove if already exists (to move to top)
      history.remove(query);

      // Add to beginning
      history.insert(0, query);

      // Keep only max items
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      await prefs.setStringList(_searchHistoryKey, history);
    } catch (e) {
      // Fail silently
    }
  }

  /// Remove specific query from history
  Future<void> removeFromHistory(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getSearchHistory();
      history.remove(query);
      await prefs.setStringList(_searchHistoryKey, history);
    } catch (e) {
      // Fail silently
    }
  }

  /// Clear all search history
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_searchHistoryKey);
    } catch (e) {
      // Fail silently
    }
  }
}
