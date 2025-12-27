import 'package:equatable/equatable.dart';

/// OCR Events
/// TR: OCR olayları - kullanıcı aksiyonları ve sistem olayları
abstract class OcrEvent extends Equatable {
  const OcrEvent();

  @override
  List<Object?> get props => [];
}

/// Resimden metin tanıma başlat
class OcrTextRecognitionRequested extends OcrEvent {
  final String imagePath;

  const OcrTextRecognitionRequested({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

/// Tanınan metni menü itemlarına parse et
class OcrMenuParsingRequested extends OcrEvent {
  final String recognizedText;

  const OcrMenuParsingRequested({required this.recognizedText});

  @override
  List<Object?> get props => [recognizedText];
}

/// Resimden direkt menü itemları çıkar (recognize + parse)
class OcrFullExtractionRequested extends OcrEvent {
  final String imagePath;

  const OcrFullExtractionRequested({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

/// OCR işlemini sıfırla
class OcrResetRequested extends OcrEvent {
  const OcrResetRequested();
}
