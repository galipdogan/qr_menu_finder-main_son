import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/utils/repository_helper.dart';
import 'package:qr_menu_finder/features/storage/domain/repositories/storage_repository.dart';
import 'package:qr_menu_finder/features/storage/data/datasources/storage_remote_data_source.dart';

class StorageRepositoryImpl implements StorageRepository {
  final StorageRemoteDataSource remoteDataSource;

  StorageRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> uploadFile(File file, String path) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.uploadFile(file, path),
      (url) => url as String,
    );
  }

  @override
  Future<Either<Failure, void>> deleteFile(String url) async {
    return RepositoryHelper.executeVoid(() => remoteDataSource.deleteFile(url));
  }
}
