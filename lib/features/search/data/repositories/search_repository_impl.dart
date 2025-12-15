import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/entities/search_response.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_data_source.dart';

/// Implementation of search repository
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SearchResponse>> searchItems(SearchQuery query) async {
    try {
      // Build filters map from search query
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

      // Execute search
      final responseModel = await remoteDataSource.searchItems(
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
      final filteredResponse = SearchResponse(
        results: results,
        totalHits: results.length,
        currentPage: query.page,
        totalPages: (results.length / query.hitsPerPage).ceil(),
        hitsPerPage: query.hitsPerPage,
      );

      return Right(filteredResponse);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } catch (e) {
      return Left(
        GeneralFailure('Unexpected error during search: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSearchSuggestions(
    String partialQuery,
  ) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.getSearchSuggestions(partialQuery),
      (suggestions) => suggestions as List<String>,
    );
  }
}
