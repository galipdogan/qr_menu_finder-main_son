import 'package:dartz/dartz.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/features/ocr/domain/entities/parsed_menu_item.dart'; // Updated Import

abstract class OcrRepository {
  Future<Either<Failure, String>> recognizeText(String imagePath);
  Future<Either<Failure, List<ParsedMenuItem>>> parseMenuText(String text);
  Future<Either<Failure, List<ParsedMenuItem>>> extractAndParseMenuItems(String imagePath);
}
