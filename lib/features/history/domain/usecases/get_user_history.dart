import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/history_entry.dart';
import '../repositories/history_repository.dart';

/// Use case for getting user's history
class GetUserHistory implements UseCase<List<HistoryEntry>, GetUserHistoryParams> {
  final HistoryRepository repository;

  GetUserHistory(this.repository);

  @override
  Future<Either<Failure, List<HistoryEntry>>> call(GetUserHistoryParams params) async {
    return await repository.getUserHistory(
      params.userId,
      limit: params.limit,
    );
  }
}

/// Parameters for getting user history
class GetUserHistoryParams extends Equatable {
  final String userId;
  final int limit;

  const GetUserHistoryParams({
    required this.userId,
    this.limit = 50,
  });

  @override
  List<Object> get props => [userId, limit];
}
