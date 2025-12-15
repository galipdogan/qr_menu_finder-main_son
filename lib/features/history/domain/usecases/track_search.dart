import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/history_repository.dart';

/// Use case for tracking a search query
class TrackSearch implements UseCase<void, TrackSearchParams> {
  final HistoryRepository repository;

  TrackSearch(this.repository);

  @override
  Future<Either<Failure, void>> call(TrackSearchParams params) async {
    return await repository.trackSearch(
      userId: params.userId,
      searchQuery: params.searchQuery,
    );
  }
}

/// Parameters for tracking search
class TrackSearchParams extends Equatable {
  final String userId;
  final String searchQuery;

  const TrackSearchParams({
    required this.userId,
    required this.searchQuery,
  });

  @override
  List<Object> get props => [userId, searchQuery];
}
