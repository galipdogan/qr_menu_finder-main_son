import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../../domain/entities/parsed_menu_item.dart';
import '../datasources/ocr_remote_data_source.dart';
import '../datasources/menu_parser_service.dart';

class OcrRepositoryImpl implements OcrRepository {
  final OcrRemoteDataSource remoteDataSource;
  final MenuParserService menuParser;

  OcrRepositoryImpl({
    required this.remoteDataSource,
    required this.menuParser,
  });

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
    try {
      // Use enhanced menu parser
      final items = await menuParser.parseMenuItems(text);
      return Right(items);
    } on OcrException catch (e) {
      return Left(OcrFailure(e.message));
    } on Exception catch (e) {
      return Left(OcrFailure('Menu parsing failed: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ParsedMenuItem>>> extractAndParseMenuItems(
    String imagePath,
  ) async {
    try {
      // Step 1: Recognize text using ML Kit
      final text = await remoteDataSource.recognizeText(imagePath);
      
      // Step 2: Parse menu items using enhanced parser
      final items = await menuParser.parseMenuItems(text);
      
      return Right(items);
    } on OcrException catch (e) {
      return Left(OcrFailure(e.message));
    } on Exception catch (e) {
      return Left(OcrFailure('OCR extraction failed: $e'));
    }
  }
}
