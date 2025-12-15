import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/history_repository.dart';

/// Use case for deleting a specific history entry
class DeleteHistoryEntry implements UseCase<void, DeleteHistoryEntryParams> {
  final HistoryRepository repository;

  DeleteHistoryEntry(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteHistoryEntryParams params) async {
    return await repository.deleteHistory(params.historyId);
  }
}

/// Parameters for deleting history entry
class DeleteHistoryEntryParams extends Equatable {
  final String historyId;

  const DeleteHistoryEntryParams({required this.historyId});

  @override
  List<Object> get props => [historyId];
}
