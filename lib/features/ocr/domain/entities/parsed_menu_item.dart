import 'package:equatable/equatable.dart';

/// Parse edilmiş menü öğesi
class ParsedMenuItem extends Equatable {
  final String name;
  final double price;
  final String currency;
  final String? description;
  final String? category;
  final double confidence; // Tanıma güvenilirlik skoru
  final String rawText; // Ham metin (eski: raw)
  
  const ParsedMenuItem({
    required this.name,
    required this.price,
    this.currency = 'TRY',
    this.description,
    this.category,
    this.confidence = 0.0,
    required this.rawText,
  });
  
  // Backward compatibility - eski 'raw' parametresi için
  factory ParsedMenuItem.fromRaw({
    required String name,
    required double price,
    String currency = 'TRY',
    String? description,
    String? category,
    double confidence = 0.0,
    required String raw,
  }) {
    return ParsedMenuItem(
      name: name,
      price: price,
      currency: currency,
      description: description,
      category: category,
      confidence: confidence,
      rawText: raw,
    );
  }
  
  /// Copy with method
  ParsedMenuItem copyWith({
    String? name,
    double? price,
    String? currency,
    String? description,
    String? category,
    double? confidence,
    String? rawText,
  }) {
    return ParsedMenuItem(
      name: name ?? this.name,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      rawText: rawText ?? this.rawText,
    );
  }
  
  /// Is valid item (has name and price)
  bool get isValid => name.isNotEmpty && price > 0;
  
  // Backward compatibility getter
  String get raw => rawText;
  
  @override
  List<Object?> get props => [
    name, 
    price, 
    currency, 
    description, 
    category, 
    confidence, 
    rawText,
  ];
}
