import 'package:equatable/equatable.dart';

/// Parsed menu item model
/// TR: Parse edilmiş menü öğesi modeli
class ParsedMenuItem extends Equatable {
  final String name;
  final double price;
  final String currency;
  final String raw; // Original line from OCR / OCR'dan orijinal satır

  const ParsedMenuItem({
    required this.name,
    required this.price,
    required this.currency,
    required this.raw,
  });

  /// Convert to Map for Firestore
  /// TR: Firestore için Map'e dönüştür
  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price, 'currency': currency, 'raw': raw};
  }

  @override
  List<Object> get props => [name, price, currency, raw];
}
