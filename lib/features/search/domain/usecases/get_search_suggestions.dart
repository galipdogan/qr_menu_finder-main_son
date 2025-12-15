import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/search_repository.dart';

/// Use case for getting search suggestions
class GetSearchSuggestions implements UseCase<List<String>, SuggestionsParams> {
  final SearchRepository repository;

  GetSearchSuggestions(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(SuggestionsParams params) async {
    if (params.partialQuery.trim().isEmpty) {
      return Right([]);
    }

    return await repository.getSearchSuggestions(params.partialQuery);
  }
}

/// Parameters for search suggestions
class SuggestionsParams extends Equatable {
  final String partialQuery;

  const SuggestionsParams({required this.partialQuery});

  @override
  List<Object> get props => [partialQuery];
}
