import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/error.dart';
import '../models/search_response_model.dart';

/// Abstract search remote data source
abstract class SearchRemoteDataSource {
  /// Search items (restaurants and menu items) using Firestore
  Future<SearchResponseModel> searchItems({
    required String query,
    Map<String, String>? filters,
    int page = 0,
    int hitsPerPage = 20,
  });

  /// Get search suggestions based on partial query
  Future<List<String>> getSearchSuggestions(String partialQuery);
}

/// Firestore implementation of search remote data source
/// Note: Basic text search - for production consider using Algolia or ElasticSearch
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final FirebaseFirestore firestore;

  // Cache for search results
  static final Map<String, SearchResponseModel> _searchCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 10);

  SearchRemoteDataSourceImpl({required this.firestore});

  @override
  Future<SearchResponseModel> searchItems({
    required String query,
    Map<String, String>? filters,
    int page = 0,
    int hitsPerPage = 20,
  }) async {
    try {
      // Check cache first
      final cacheKey = '${query}_${page}_$hitsPerPage';
      final cached = _getCachedResults(cacheKey);
      if (cached != null) {
        return cached;
      }

      final queryLower = query.toLowerCase();
      final List<Map<String, dynamic>> allHits = [];

      // OPTIMIZED: Search restaurants with WHERE clause
      // Only fetch active restaurants
      final restaurantsQuery = await firestore
          .collection('restaurants')
          .where('isActive', isEqualTo: true)
          .limit(hitsPerPage * 2) // Fetch more to account for filtering
          .get();

      for (var doc in restaurantsQuery.docs) {
        final data = doc.data();
        final name = (data['name'] as String?)?.toLowerCase() ?? '';
        final categories = (data['categories'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];
        
        // Search in name and categories
        if (name.contains(queryLower) || categories.any((cat) => cat.contains(queryLower))) {
          allHits.add({...data, 'id': doc.id, 'type': 'restaurant'});
        }
      }

      // OPTIMIZED: Search menu items - only if we need more results
      if (allHits.length < hitsPerPage) {
        final menuItemsQuery = await firestore
            .collection('menuItems')
            .limit(hitsPerPage)
            .get();

        for (var doc in menuItemsQuery.docs) {
          final data = doc.data();
          final name = (data['name'] as String?)?.toLowerCase() ?? '';
          final description = (data['description'] as String?)?.toLowerCase() ?? '';
          
          // Search in name and description
          if (name.contains(queryLower) || description.contains(queryLower)) {
            allHits.add({...data, 'id': doc.id, 'type': 'menuItem'});
          }
        }
      }

      // Simple pagination
      final startIndex = page * hitsPerPage;
      final endIndex = (startIndex + hitsPerPage).clamp(0, allHits.length);
      final paginatedHits = allHits.sublist(
        startIndex.clamp(0, allHits.length),
        endIndex,
      );

      final result = SearchResponseModel.fromAlgoliaResponse(
        hits: paginatedHits,
        nbHits: allHits.length,
        page: page,
        nbPages: (allHits.length / hitsPerPage).ceil(),
        hitsPerPage: hitsPerPage,
      );

      // Cache the result
      _cacheResults(cacheKey, result);

      return result;
    } catch (e, stackTrace) {
      throw ServerException(
        'Firestore search failed: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  SearchResponseModel? _getCachedResults(String cacheKey) {
    final cache = _searchCache[cacheKey];
    final timestamp = _cacheTimestamps[cacheKey];

    if (cache == null || timestamp == null) {
      return null;
    }

    if (DateTime.now().difference(timestamp) >= _cacheExpiry) {
      _searchCache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
      return null;
    }

    return cache;
  }

  void _cacheResults(String cacheKey, SearchResponseModel result) {
    _searchCache[cacheKey] = result;
    _cacheTimestamps[cacheKey] = DateTime.now();
  }

  @override
  Future<List<String>> getSearchSuggestions(String partialQuery) async {
    try {
      if (partialQuery.length < 2) return [];

      final queryLower = partialQuery.toLowerCase();
      final suggestions = <String>{};

      // OPTIMIZED: Only get active restaurants with limit
      final restaurantsQuery = await firestore
          .collection('restaurants')
          .where('isActive', isEqualTo: true)
          .limit(10) // Increased limit for better suggestions
          .get();

      for (var doc in restaurantsQuery.docs) {
        final data = doc.data();
        final name = data['name'] as String?;
        final categories = (data['categories'] as List?)?.cast<String>() ?? [];
        
        if (name != null && name.toLowerCase().contains(queryLower)) {
          suggestions.add(name);
        }
        
        // Also suggest categories
        for (final category in categories) {
          if (category.toLowerCase().contains(queryLower)) {
            suggestions.add(category);
          }
        }
        
        if (suggestions.length >= 5) break;
      }

      return suggestions.take(5).toList();
    } catch (e, stackTrace) {
      throw ServerException(
        'Failed to get search suggestions: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }
}
