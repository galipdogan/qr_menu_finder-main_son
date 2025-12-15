import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/search_query.dart';
import '../entities/search_response.dart';
import '../repositories/search_repository.dart';

/// Use case for searching items (restaurants and menu items)
class SearchItems implements UseCase<SearchResponse, SearchQuery> {
  final SearchRepository repository;

  SearchItems(this.repository);

  @override
  Future<Either<Failure, SearchResponse>> call(SearchQuery params) async {
    // Validate query
    if (params.query.trim().isEmpty) {
      return Left(ValidationFailure('Search query cannot be empty'));
    }

    return await repository.searchItems(params);
  }
}
