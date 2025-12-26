import 'package:meilisearch/meilisearch.dart';
import '../../../../core/error/error.dart';
import '../../../../core/config/meilisearch_config.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/search_response_model.dart';

/// MeiliSearch remote data source for advanced search capabilities
abstract class MeiliSearchRemoteDataSource {
  /// Search items using MeiliSearch
  Future<SearchResponseModel> searchItems({
    required String query,
    Map<String, String>? filters,
    int page = 0,
    int hitsPerPage = 20,
  });

  /// Get search suggestions
  Future<List<String>> getSearchSuggestions(String partialQuery);

  /// Index a document in MeiliSearch
  Future<void> indexDocument(String indexName, Map<String, dynamic> document);

  /// Delete a document from MeiliSearch
  Future<void> deleteDocument(String indexName, String documentId);

  /// Update MeiliSearch settings
  Future<void> updateIndexSettings(
    String indexName,
    Map<String, dynamic> settings,
  );
}

/// Implementation of MeiliSearch remote data source
class MeiliSearchRemoteDataSourceImpl implements MeiliSearchRemoteDataSource {
  final MeiliSearchClient client;

  // Index names
  // Index names
  static const String restaurantsIndex = MeiliSearchConfig.restaurantsIndexName;
  static const String menuItemsIndex = MeiliSearchConfig.menuItemsIndexName;

  MeiliSearchRemoteDataSourceImpl({required this.client});

  @override
  Future<SearchResponseModel> searchItems({
    required String query,
    Map<String, String>? filters,
    int page = 0,
    int hitsPerPage = 20,
  }) async {
    try {
      AppLogger.i('MeiliSearch: Searching for "$query" (page: $page)');

      final filterList = <String>[];
      if (filters != null) {
        filters.forEach((key, value) {
          filterList.add('$key = "$value"');
        });
      }

      final restaurantsResult = await client.index(restaurantsIndex).search(
        query,
        SearchQuery(
          filter: filterList.isNotEmpty ? filterList.join(' AND ') : null,
          offset: page * hitsPerPage,
          limit: hitsPerPage,
        ),
      );

      final menuItemsResult = await client.index(menuItemsIndex).search(
        query,
        SearchQuery(
          filter: filterList.isNotEmpty ? filterList.join(' AND ') : null,
          offset: page * hitsPerPage,
          limit: hitsPerPage,
        ),
      );

      final allHits = <Map<String, dynamic>>[];
      int totalHits = 0;

      totalHits += restaurantsResult.hits.length;
      for (final hit in restaurantsResult.hits) {
        final hitData = Map<String, dynamic>.from(hit);
        hitData['type'] = 'restaurant';
        allHits.add(hitData);
      }

      totalHits += menuItemsResult.hits.length;
      for (final hit in menuItemsResult.hits) {
        final hitData = Map<String, dynamic>.from(hit);
        hitData['type'] = 'menuItem';
        allHits.add(hitData);
      }

      return SearchResponseModel.fromMeiliSearchResponse(
        hits: allHits,
        totalHits: totalHits,
        offset: page * hitsPerPage,
        limit: hitsPerPage,
      );
    } catch (e, stackTrace) {
      AppLogger.e('MeiliSearch error', error: e, stackTrace: stackTrace);
      throw ServerException(
        'MeiliSearch failed: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<String>> getSearchSuggestions(String partialQuery) async {
    try {
      if (partialQuery.length < 2) return [];

      AppLogger.i('MeiliSearch: Getting suggestions for "$partialQuery"');

      // Search with prefix matching
      final results = await client
          .index(restaurantsIndex)
          .search(
            partialQuery,
            SearchQuery(
              limit: 5,
            ),
          );

      final suggestions = results.hits
          .map((hit) => hit['name'] as String?)
          .whereType<String>()
          .toList();

      AppLogger.i('MeiliSearch: Found ${suggestions.length} suggestions');
      return suggestions;
    } catch (e, stackTrace) {
      AppLogger.e(
        'MeiliSearch suggestions error',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException(
        'Failed to get suggestions: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> indexDocument(
    String indexName,
    Map<String, dynamic> document,
  ) async {
    try {
      AppLogger.i('MeiliSearch: Indexing document in $indexName');

      final index = client.index(indexName);
      await index.addDocuments([document]);

      AppLogger.i('MeiliSearch: Document indexed successfully');
    } catch (e, stackTrace) {
      AppLogger.e(
        'MeiliSearch indexing error',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException(
        'Failed to index document: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteDocument(String indexName, String documentId) async {
    try {
      AppLogger.i('MeiliSearch: Deleting document $documentId from $indexName');

      final index = client.index(indexName);
      await index.deleteDocument(documentId);

      AppLogger.i('MeiliSearch: Document deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.e('MeiliSearch delete error', error: e, stackTrace: stackTrace);
      throw ServerException(
        'Failed to delete document: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateIndexSettings(
    String indexName,
    Map<String, dynamic> settings,
  ) async {
    try {
      AppLogger.i('MeiliSearch: Updating settings for $indexName');

      final index = client.index(indexName);

      // Update searchable attributes
      if (settings.containsKey('searchableAttributes')) {
        await index.updateSearchableAttributes(
          settings['searchableAttributes'] as List<String>,
        );
      }

      // Update filterable attributes
      if (settings.containsKey('filterableAttributes')) {
        await index.updateFilterableAttributes(
          settings['filterableAttributes'] as List<String>,
        );
      }

      // Update sortable attributes
      if (settings.containsKey('sortableAttributes')) {
        await index.updateSortableAttributes(
          settings['sortableAttributes'] as List<String>,
        );
      }

      AppLogger.i('MeiliSearch: Settings updated successfully');
    } catch (e, stackTrace) {
      AppLogger.e(
        'MeiliSearch settings error',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException(
        'Failed to update settings: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }
}