import 'package:dartz/dartz.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/utils/repository_helper.dart';
import 'package:qr_menu_finder/features/ocr/domain/repositories/ocr_repository.dart';
import 'package:qr_menu_finder/features/ocr/data/datasources/ocr_remote_data_source.dart';
import 'package:qr_menu_finder/features/ocr/domain/entities/parsed_menu_item.dart';

class OcrRepositoryImpl implements OcrRepository {
  final OcrRemoteDataSource remoteDataSource;

  OcrRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> recognizeText(String imagePath) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.recognizeText(imagePath),
      (text) => text as String,
    );
  }

  @override
  Future<Either<Failure, List<ParsedMenuItem>>> parseMenuText(
    String text,
  ) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.parseMenuText(text),
      (items) => items as List<ParsedMenuItem>,
    );
  }

  @override
  Future<Either<Failure, List<ParsedMenuItem>>> extractAndParseMenuItems(
    String imagePath,
  ) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.extractAndParseMenuItems(imagePath),
      (items) => items as List<ParsedMenuItem>,
    );
  }
}
