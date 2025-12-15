import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/storage/domain/repositories/storage_repository.dart';

class UploadFile implements UseCase<String, UploadFileParams> {
  final StorageRepository repository;

  UploadFile(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadFileParams params) async {
    return await repository.uploadFile(params.file, params.path);
  }
}

class UploadFileParams extends Equatable {
  final File file;
  final String path; // Path in storage, e.g., 'images/menus/restaurantId/image.jpg'

  const UploadFileParams({required this.file, required this.path});

  @override
  List<Object> get props => [file, path];
}
