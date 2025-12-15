import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:qr_menu_finder/core/error/failures.dart';

abstract class StorageRepository {
  Future<Either<Failure, String>> uploadFile(File file, String path);
  Future<Either<Failure, void>> deleteFile(String url);
}
