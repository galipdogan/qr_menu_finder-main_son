import '../../domain/entities/parsed_menu_item.dart';
import '../../../../core/error/exceptions.dart';

/// Enhanced menu parser with Turkish language support
/// TR: Türkçe dil desteği ile gelişmiş menü parser
class MenuParserService {
  // Common Turkish menu categories
  static const Map<String, List<String>> _categoryKeywords = {
    'Başlangıçlar': ['başlangıç', 'mezze', 'soğuk', 'sıcak'],
    'Çorbalar': ['çorba', 'çorbası'],
    'Ana Yemekler': ['ana yemek', 'et', 'tavuk', 'balık'],
    'Salatalar': ['salata'],
    'Pizzalar': ['pizza'],
    'Burgerler': ['burger', 'hamburger'],
    'Tatlılar': ['tatlı', 'tatlılar', 'pasta', 'dondurma'],
    'İçecekler': ['içecek', 'meşrubat', 'su', 'çay', 'kahve'],
  };
  
  /// Parse menu items from OCR text
  Future<List<ParsedMenuItem>> parseMenuItems(String text) async {
    try {
      final lines = _cleanAndSplitLines(text);
      final items = <ParsedMenuItem>[];
      String? currentCategory;
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        
        // Check if line is a category header
        final category = _detectCategory(line);
        if (category != null) {
          currentCategory = category;
          continue;
        }
        
        // Try to parse as menu item
        final item = _parseMenuItem(line, currentCategory);
        if (item != null && item.isValid) {
          items.add(item);
        } else {
          // Try multi-line parsing (name on one line, price on next)
          if (i < lines.length - 1) {
            final multiLineItem = _parseMultiLineItem(
              line,
              lines[i + 1],
              currentCategory,
            );
            if (multiLineItem != null && multiLineItem.isValid) {
              items.add(multiLineItem);
              i++; // Skip next line
            }
          }
        }
      }
      
      return items;
    } catch (e) {
      throw OcrException('Menu parsing failed: $e');
    }
  }
  
  List<String> _cleanAndSplitLines(String text) {
    return text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }
  
  String? _detectCategory(String line) {
    final lowerLine = line.toLowerCase();
    
    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerLine.contains(keyword)) {
          return entry.key;
        }
      }
    }
    
    return null;
  }
  
  ParsedMenuItem? _parseMenuItem(String line, String? category) {
    // Pattern 1: "Name ... Price₺"
    // Pattern 2: "Name Price₺"
    // Pattern 3: "Name ₺Price"
    // Pattern 4: "Name Price TL"
    
    final pricePatterns = [
      RegExp(r'(.+?)\s*[\.]+\s*(\d+(?:[.,]\d+)?)\s*([₺TL]+)', caseSensitive: false),
      RegExp(r'(.+?)\s+(\d+(?:[.,]\d+)?)\s*([₺TL]+)', caseSensitive: false),
      RegExp(r'(.+?)\s*([₺]+)\s*(\d+(?:[.,]\d+)?)', caseSensitive: false),
      RegExp(r'(.+?)\s+(\d+(?:[.,]\d+)?)\s+(TL|tl)', caseSensitive: false),
    ];
    
    for (final pattern in pricePatterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        String name = match.group(1)?.trim() ?? '';
        String priceStr = '';
        String currency = 'TRY';
        
        // Extract price based on pattern
        if (pattern == pricePatterns[0] || pattern == pricePatterns[1]) {
          priceStr = match.group(2) ?? '';
          currency = _normalizeCurrency(match.group(3) ?? '₺');
        } else if (pattern == pricePatterns[2]) {
          priceStr = match.group(3) ?? '';
          currency = _normalizeCurrency(match.group(2) ?? '₺');
        } else {
          priceStr = match.group(2) ?? '';
          currency = 'TRY';
        }
        
        // Clean and parse price
        priceStr = priceStr.replaceAll(',', '.');
        final price = double.tryParse(priceStr);
        
        if (price != null && price > 0 && name.isNotEmpty) {
          // Extract description (if any)
          final descMatch = RegExp(r'\(([^)]+)\)').firstMatch(name);
          String? description;
          if (descMatch != null) {
            description = descMatch.group(1);
            name = name.replaceAll(descMatch.group(0)!, '').trim();
          }
          
          return ParsedMenuItem(
            name: _cleanName(name),
            price: price,
            currency: currency,
            description: description,
            category: category,
            confidence: 0.8,
            rawText: line,
          );
        }
      }
    }
    
    return null;
  }
  
  ParsedMenuItem? _parseMultiLineItem(
    String nameLine,
    String priceLine,
    String? category,
  ) {
    // Check if price line contains only price
    final pricePattern = RegExp(r'^\s*(\d+(?:[.,]\d+)?)\s*([₺TL]+)\s*$', caseSensitive: false);
    final match = pricePattern.firstMatch(priceLine);
    
    if (match != null && nameLine.length > 3) {
      final priceStr = match.group(1)?.replaceAll(',', '.') ?? '';
      final price = double.tryParse(priceStr);
      final currency = _normalizeCurrency(match.group(2) ?? '₺');
      
      if (price != null && price > 0) {
        return ParsedMenuItem(
          name: _cleanName(nameLine),
          price: price,
          currency: currency,
          category: category,
          confidence: 0.7,
          rawText: '$nameLine\n$priceLine',
        );
      }
    }
    
    return null;
  }
  
  String _cleanName(String name) {
    return name
        .replaceAll(RegExp(r'[\.]{2,}'), '') // Remove dots
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize spaces
        .trim();
  }
  
  String _normalizeCurrency(String currency) {
    final lower = currency.toLowerCase();
    if (lower.contains('tl') || lower.contains('₺')) {
      return 'TRY';
    }
    return 'TRY';
  }
}
