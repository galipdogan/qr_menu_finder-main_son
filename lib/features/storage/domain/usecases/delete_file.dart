import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/storage/domain/repositories/storage_repository.dart';

class DeleteFile implements UseCase<void, DeleteFileParams> {
  final StorageRepository repository;

  DeleteFile(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteFileParams params) async {
    return await repository.deleteFile(params.url);
  }
}

class DeleteFileParams extends Equatable {
  final String url; // URL of the file to delete

  const DeleteFileParams({required this.url});

  @override
  List<Object> get props => [url];
}
