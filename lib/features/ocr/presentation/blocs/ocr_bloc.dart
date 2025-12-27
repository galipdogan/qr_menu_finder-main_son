import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/extract_and_parse_menu_items_from_image.dart';
import '../../domain/usecases/parse_text_to_menu_items.dart';
import '../../domain/usecases/recognize_text_from_image.dart';
import '../../../../core/utils/app_logger.dart';
import 'ocr_event.dart';
import 'ocr_state.dart';

/// OCR Bloc
/// TR: OCR iş mantığı - metin tanıma ve menü parse işlemlerini yönetir
class OcrBloc extends Bloc<OcrEvent, OcrState> {
  final RecognizeTextFromImage recognizeTextFromImage;
  final ParseTextToMenuItems parseTextToMenuItems;
  final ExtractAndParseMenuItemsFromImage extractAndParseMenuItemsFromImage;

  OcrBloc({
    required this.recognizeTextFromImage,
    required this.parseTextToMenuItems,
    required this.extractAndParseMenuItemsFromImage,
  }) : super(const OcrInitial()) {
    on<OcrTextRecognitionRequested>(_onTextRecognitionRequested);
    on<OcrMenuParsingRequested>(_onMenuParsingRequested);
    on<OcrFullExtractionRequested>(_onFullExtractionRequested);
    on<OcrResetRequested>(_onResetRequested);
  }

  /// Sadece metin tanıma
  Future<void> _onTextRecognitionRequested(
    OcrTextRecognitionRequested event,
    Emitter<OcrState> emit,
  ) async {
    AppLogger.i('OcrBloc: Text recognition requested for ${event.imagePath}');
    emit(const OcrRecognizing());

    final result = await recognizeTextFromImage(
      RecognizeTextFromImageParams(imagePath: event.imagePath),
    );

    result.fold(
      (failure) {
        AppLogger.e('OcrBloc: Text recognition failed', error: failure.message);
        emit(OcrError(message: failure.userMessage));
      },
      (recognizedText) {
        AppLogger.i('OcrBloc: Text recognized successfully');
        emit(OcrTextRecognized(recognizedText: recognizedText));
      },
    );
  }

  /// Sadece menü parse
  Future<void> _onMenuParsingRequested(
    OcrMenuParsingRequested event,
    Emitter<OcrState> emit,
  ) async {
    AppLogger.i('OcrBloc: Menu parsing requested');
    emit(OcrParsing(text: event.recognizedText));

    final result = await parseTextToMenuItems(
      ParseTextToMenuItemsParams(text: event.recognizedText),
    );

    result.fold(
      (failure) {
        AppLogger.e('OcrBloc: Menu parsing failed', error: failure.message);
        emit(OcrError(message: failure.userMessage));
      },
      (menuItems) {
        AppLogger.i('OcrBloc: Parsed ${menuItems.length} menu items');
        emit(OcrMenuParsed(
          menuItems: menuItems,
          recognizedText: event.recognizedText,
        ));
      },
    );
  }

  /// Full pipeline: recognize + parse
  Future<void> _onFullExtractionRequested(
    OcrFullExtractionRequested event,
    Emitter<OcrState> emit,
  ) async {
    AppLogger.i('OcrBloc: Full extraction requested for ${event.imagePath}');
    emit(const OcrRecognizing());

    final result = await extractAndParseMenuItemsFromImage(
      ExtractAndParseMenuItemsFromImageParams(imagePath: event.imagePath),
    );

    result.fold(
      (failure) {
        AppLogger.e('OcrBloc: Full extraction failed', error: failure.message);
        emit(OcrError(message: failure.userMessage));
      },
      (menuItems) {
        AppLogger.i('OcrBloc: Extracted ${menuItems.length} menu items');
        emit(OcrMenuParsed(menuItems: menuItems));
      },
    );
  }

  /// Reset
  Future<void> _onResetRequested(
    OcrResetRequested event,
    Emitter<OcrState> emit,
  ) async {
    AppLogger.i('OcrBloc: Reset requested');
    emit(const OcrInitial());
  }
}
