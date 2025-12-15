import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/search_query.dart';
import '../entities/search_response.dart';

/// Search repository interface for clean architecture
abstract class SearchRepository {
  /// Search for items (restaurants and menu items) using Algolia
  Future<Either<Failure, SearchResponse>> searchItems(SearchQuery query);

  /// Get search suggestions based on partial query
  Future<Either<Failure, List<String>>> getSearchSuggestions(String partialQuery);
}
