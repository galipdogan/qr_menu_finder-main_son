import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/history_repository.dart';

/// Use case for clearing user's history
class ClearHistory implements UseCase<void, ClearHistoryParams> {
  final HistoryRepository repository;

  ClearHistory(this.repository);

  @override
  Future<Either<Failure, void>> call(ClearHistoryParams params) async {
    return await repository.clearUserHistory(params.userId);
  }
}

/// Parameters for clearing history
class ClearHistoryParams extends Equatable {
  final String userId;

  const ClearHistoryParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
