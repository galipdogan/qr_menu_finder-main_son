import 'package:dartz/dartz.dart';
import '../../../../core/config/meilisearch_config.dart';
import '../../../../core/error/error.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/entities/search_response.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/meilisearch_remote_data_source.dart';
import '../datasources/search_remote_data_source.dart';

/// Hybrid search repository that uses MeiliSearch when available,
/// falls back to Firestore when MeiliSearch is disabled or fails
class HybridSearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource firestoreDataSource;
  final MeiliSearchRemoteDataSource? meilisearchDataSource;

  HybridSearchRepositoryImpl({
    required this.firestoreDataSource,
    this.meilisearchDataSource,
  });

  @override
  Future<Either<Failure, SearchResponse>> searchItems(SearchQuery query) async {
    // Try MeiliSearch first if enabled
    if (MeiliSearchConfig.isEnabled && meilisearchDataSource != null) {
      AppLogger.i('Using MeiliSearch for search');

      final result = await _searchWithMeiliSearch(query);

      // If MeiliSearch fails, fall back to Firestore
      return result.fold((failure) {
        AppLogger.w(
          'MeiliSearch failed, falling back to Firestore: ${failure.message}',
        );
        return _searchWithFirestore(query);
      }, (response) => Right(response));
    }

    // Use Firestore if MeiliSearch is disabled
    AppLogger.i('Using Firestore for search');
    return _searchWithFirestore(query);
  }

  /// Search using MeiliSearch
  Future<Either<Failure, SearchResponse>> _searchWithMeiliSearch(
    SearchQuery query,
  ) async {
    return RepositoryHelper.execute(() async {
      // Build filters map
      final filters = <String, String>{};
      if (query.city != null && query.city!.isNotEmpty) {
        filters['city'] = query.city!;
      }
      if (query.district != null && query.district!.isNotEmpty) {
        filters['district'] = query.district!;
      }
      if (query.category != null && query.category!.isNotEmpty) {
        filters['category'] = query.category!;
      }

      final responseModel = await meilisearchDataSource!.searchItems(
        query: query.query,
        filters: filters.isNotEmpty ? filters : null,
        page: query.page,
        hitsPerPage: query.hitsPerPage,
      );

      // Apply client-side filtering for price and rating
      var results = responseModel.results;

      // Filter by price range
      if (query.minPrice != null || query.maxPrice != null) {
        results = results.where((result) {
          if (result.price == null) return false;
          final price = result.price!;
          if (query.minPrice != null && price < query.minPrice!) return false;
          if (query.maxPrice != null && price > query.maxPrice!) return false;
          return true;
        }).toList();
      }

      // Filter by minimum rating
      if (query.minRating != null) {
        results = results.where((result) {
          if (result.rating == null) return false;
          return result.rating! >= query.minRating!;
        }).toList();
      }

      // Create filtered response
      return SearchResponse(
        results: results,
        totalHits: results.length,
        currentPage: query.page,
        totalPages: (results.length / query.hitsPerPage).ceil(),
        hitsPerPage: query.hitsPerPage,
      );
    }, (response) => response as SearchResponse);
  }

  /// Search using Firestore (fallback)
  Future<Either<Failure, SearchResponse>> _searchWithFirestore(
    SearchQuery query,
  ) async {
    return RepositoryHelper.execute(() async {
      // Build filters map
      final filters = <String, String>{};
      if (query.city != null && query.city!.isNotEmpty) {
        filters['city'] = query.city!;
      }
      if (query.district != null && query.district!.isNotEmpty) {
        filters['district'] = query.district!;
      }
      if (query.category != null && query.category!.isNotEmpty) {
        filters['category'] = query.category!;
      }

      final responseModel = await firestoreDataSource.searchItems(
        query: query.query,
        filters: filters.isNotEmpty ? filters : null,
        page: query.page,
        hitsPerPage: query.hitsPerPage,
      );

      // Apply client-side filtering for price and rating
      var results = responseModel.results;

      // Filter by price range
      if (query.minPrice != null || query.maxPrice != null) {
        results = results.where((result) {
          if (result.price == null) return false;
          final price = result.price!;
          if (query.minPrice != null && price < query.minPrice!) return false;
          if (query.maxPrice != null && price > query.maxPrice!) return false;
          return true;
        }).toList();
      }

      // Filter by minimum rating
      if (query.minRating != null) {
        results = results.where((result) {
          if (result.rating == null) return false;
          return result.rating! >= query.minRating!;
        }).toList();
      }

      // Create filtered response
      return SearchResponse(
        results: results,
        totalHits: results.length,
        currentPage: query.page,
        totalPages: (results.length / query.hitsPerPage).ceil(),
        hitsPerPage: query.hitsPerPage,
      );
    }, (response) => response as SearchResponse);
  }

  @override
  Future<Either<Failure, List<String>>> getSearchSuggestions(
    String partialQuery,
  ) async {
    // Try MeiliSearch first if enabled
    if (MeiliSearchConfig.isEnabled && meilisearchDataSource != null) {
      AppLogger.i('Using MeiliSearch for suggestions');

      final result = await RepositoryHelper.execute(
        () => meilisearchDataSource!.getSearchSuggestions(partialQuery),
        (suggestions) => suggestions as List<String>,
      );

      // If MeiliSearch fails, fall back to Firestore
      return result.fold((failure) {
        AppLogger.w(
          'MeiliSearch suggestions failed, falling back to Firestore',
        );
        return RepositoryHelper.execute(
          () => firestoreDataSource.getSearchSuggestions(partialQuery),
          (suggestions) => suggestions as List<String>,
        );
      }, (suggestions) => Right(suggestions));
    }

    // Use Firestore if MeiliSearch is disabled
    AppLogger.i('Using Firestore for suggestions');
    return RepositoryHelper.execute(
      () => firestoreDataSource.getSearchSuggestions(partialQuery),
      (suggestions) => suggestions as List<String>,
    );
  }
}
