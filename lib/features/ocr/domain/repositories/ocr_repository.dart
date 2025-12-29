import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/parsed_menu_item.dart';

/// OCR Repository interface
abstract class OcrRepository {
  /// Recognize text from image and parse menu items
  Future<Either<Failure, String>> recognizeText(String imagePath);
  
  /// Parse menu items from text
  Future<Either<Failure, List<ParsedMenuItem>>> parseMenuText(String text);
  
  /// Full extraction: recognize + parse (main method)
  Future<Either<Failure, List<ParsedMenuItem>>> extractAndParseMenuItems(
    String imagePath,
  );
}
