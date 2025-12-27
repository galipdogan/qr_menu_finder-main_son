import 'package:equatable/equatable.dart';
import '../../domain/entities/parsed_menu_item.dart';

/// OCR States
/// TR: OCR durumları - işlem sonuçları ve hata durumları
abstract class OcrState extends Equatable {
  const OcrState();

  @override
  List<Object?> get props => [];
}

/// Başlangıç durumu
class OcrInitial extends OcrState {
  const OcrInitial();
}

/// Metin tanıma işlemi devam ediyor
class OcrRecognizing extends OcrState {
  const OcrRecognizing();
}

/// Metin başarıyla tanındı
class OcrTextRecognized extends OcrState {
  final String recognizedText;

  const OcrTextRecognized({required this.recognizedText});

  @override
  List<Object?> get props => [recognizedText];
}

/// Menü parse işlemi devam ediyor
class OcrParsing extends OcrState {
  final String text;

  const OcrParsing({required this.text});

  @override
  List<Object?> get props => [text];
}

/// Menü itemları başarıyla parse edildi
class OcrMenuParsed extends OcrState {
  final List<ParsedMenuItem> menuItems;
  final String? recognizedText;

  const OcrMenuParsed({
    required this.menuItems,
    this.recognizedText,
  });

  @override
  List<Object?> get props => [menuItems, recognizedText];
}

/// OCR işlemi başarısız
class OcrError extends OcrState {
  final String message;

  const OcrError({required this.message});

  @override
  List<Object?> get props => [message];
}
