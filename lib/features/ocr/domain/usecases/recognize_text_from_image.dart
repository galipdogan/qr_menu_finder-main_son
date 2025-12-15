import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/ocr/domain/repositories/ocr_repository.dart';

class RecognizeTextFromImage implements UseCase<String, RecognizeTextFromImageParams> {
  final OcrRepository repository;

  RecognizeTextFromImage(this.repository);

  @override
  Future<Either<Failure, String>> call(RecognizeTextFromImageParams params) async {
    return await repository.recognizeText(params.imagePath);
  }
}

class RecognizeTextFromImageParams extends Equatable {
  final String imagePath;

  const RecognizeTextFromImageParams({required this.imagePath});

  @override
  List<Object> get props => [imagePath];
}
