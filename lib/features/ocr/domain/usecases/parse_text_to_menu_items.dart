import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/ocr/domain/repositories/ocr_repository.dart';
import 'package:qr_menu_finder/features/ocr/domain/entities/parsed_menu_item.dart';

class ParseTextToMenuItems implements UseCase<List<ParsedMenuItem>, ParseTextToMenuItemsParams> {
  final OcrRepository repository;

  ParseTextToMenuItems(this.repository);

  @override
  Future<Either<Failure, List<ParsedMenuItem>>> call(ParseTextToMenuItemsParams params) async {
    return await repository.parseMenuText(params.text);
  }
}

class ParseTextToMenuItemsParams extends Equatable {
  final String text;

  const ParseTextToMenuItemsParams({required this.text});

  @override
  List<Object> get props => [text];
}
