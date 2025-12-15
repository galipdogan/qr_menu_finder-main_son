import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/ocr/domain/repositories/ocr_repository.dart';
import 'package:qr_menu_finder/features/ocr/domain/entities/parsed_menu_item.dart';

class ExtractAndParseMenuItemsFromImage implements UseCase<List<ParsedMenuItem>, ExtractAndParseMenuItemsFromImageParams> {
  final OcrRepository repository;

  ExtractAndParseMenuItemsFromImage(this.repository);

  @override
  Future<Either<Failure, List<ParsedMenuItem>>> call(ExtractAndParseMenuItemsFromImageParams params) async {
    return await repository.extractAndParseMenuItems(params.imagePath);
  }
}

class ExtractAndParseMenuItemsFromImageParams extends Equatable {
  final String imagePath;

  const ExtractAndParseMenuItemsFromImageParams({required this.imagePath});

  @override
  List<Object> get props => [imagePath];
}
