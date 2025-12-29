import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../domain/entities/parsed_menu_item.dart';

/// Abstract OCR data source
abstract class OcrRemoteDataSource {
  Future<String> recognizeText(String imagePath);
  Future<List<ParsedMenuItem>> parseMenuText(String text);
  Future<List<ParsedMenuItem>> extractAndParseMenuItems(String imagePath);
  void closeRecognizer();
}

/// ML Kit implementation
class MLKitOcrDataSourceImpl implements OcrRemoteDataSource {
  late final TextRecognizer _textRecognizer;

  MLKitOcrDataSourceImpl() {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    debugPrint('✅ ML Kit OCR initialized');
  }

  /// STEP 1 — Recognize raw text from image
  @override
  Future<String> recognizeText(String imagePath) async {
    try {
      debugPrint('🔍 OCR: Recognizing text...');
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('❌ OCR error: $e');
      throw Exception('Failed to recognize text: $e');
    }
  }

  /// STEP 2 — Parse recognized text into menu items
  @override
  Future<List<ParsedMenuItem>> parseMenuText(String text) async {
    try {
      debugPrint('🔍 OCR: Parsing menu text...');
      final lines = text
          .split(RegExp(r'\r?\n'))
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      debugPrint('📄 OCR: Found ${lines.length} lines');

      final items = <ParsedMenuItem>[];

      final priceRegex = RegExp(
        r'([0-9]{1,4}(?:[.,][0-9]{1,2})?)\s*(tl|₺|try)?',
        caseSensitive: false,
      );

      for (final line in lines) {
        final match = priceRegex.firstMatch(line);
        if (match != null) {
          final priceStr = match.group(1)!.replaceAll(',', '.');
          final price = double.tryParse(priceStr);

          if (price != null && price > 0) {
            final name = line.substring(0, match.start).trim();

            if (name.isNotEmpty) {
              items.add(
                ParsedMenuItem(
                  name: name,
                  price: price,
                  currency: 'TRY',
                  rawText: line,
                ),
              );
            }
          }
        }
      }

      debugPrint('✅ OCR: Parsed ${items.length} menu items');
      return items;
    } catch (e) {
      debugPrint('❌ OCR parsing error: $e');
      throw Exception('Failed to parse menu text: $e');
    }
  }

  /// STEP 3 — Full pipeline: Recognize + Parse
  @override
  Future<List<ParsedMenuItem>> extractAndParseMenuItems(
    String imagePath,
  ) async {
    try {
      debugPrint('🔍 OCR: Extracting & parsing...');
      final text = await recognizeText(imagePath);
      final items = await parseMenuText(text);
      debugPrint('✅ OCR: Extracted ${items.length} items');
      return items;
    } catch (e) {
      debugPrint('❌ OCR extract+parse error: $e');
      rethrow;
    }
  }

  /// Cleanup
  @override
  void closeRecognizer() {
    _textRecognizer.close();
    debugPrint('🗑️ OCR recognizer closed');
  }
}
