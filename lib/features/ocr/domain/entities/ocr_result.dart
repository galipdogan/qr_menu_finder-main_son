import 'package:equatable/equatable.dart';

/// OCR tanıma sonucu
class OcrResult extends Equatable {
  final String text;
  final double confidence;
  final String language;
  final List<TextBlock> blocks;
  
  const OcrResult({
    required this.text,
    required this.confidence,
    required this.language,
    required this.blocks,
  });
  
  @override
  List<Object?> get props => [text, confidence, language, blocks];
}

/// Metin bloğu (paragraf, satır vb.)
class TextBlock extends Equatable {
  final String text;
  final double confidence;
  final BoundingBox boundingBox;
  final List<TextLine> lines;
  
  const TextBlock({
    required this.text,
    required this.confidence,
    required this.boundingBox,
    required this.lines,
  });
  
  @override
  List<Object?> get props => [text, confidence, boundingBox, lines];
}

/// Metin satırı
class TextLine extends Equatable {
  final String text;
  final double confidence;
  final BoundingBox boundingBox;
  
  const TextLine({
    required this.text,
    required this.confidence,
    required this.boundingBox,
  });
  
  @override
  List<Object?> get props => [text, confidence, boundingBox];
}

/// Bounding box koordinatları
class BoundingBox extends Equatable {
  final double left;
  final double top;
  final double width;
  final double height;
  
  const BoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
  
  @override
  List<Object?> get props => [left, top, width, height];
}
