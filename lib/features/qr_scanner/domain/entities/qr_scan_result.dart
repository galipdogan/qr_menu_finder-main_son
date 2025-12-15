import 'package:equatable/equatable.dart';

/// QR Scan result type enumeration
enum QRScanType {
  restaurant,
  menu,
  addMenu,
}

/// Domain entity for QR scan result
class QRScanResult extends Equatable {
  final QRScanType type;
  final String? id; // Restaurant ID or Menu ID
  final String? content; // Raw QR content
  final bool? isUrl; // Is content a URL?

  const QRScanResult({
    required this.type,
    this.id,
    this.content,
    this.isUrl,
  });

  /// Create restaurant scan result
  factory QRScanResult.restaurant(String restaurantId) {
    return QRScanResult(
      type: QRScanType.restaurant,
      id: restaurantId,
    );
  }

  /// Create menu scan result
  factory QRScanResult.menu(String menuId) {
    return QRScanResult(
      type: QRScanType.menu,
      id: menuId,
    );
  }

  /// Create add menu scan result
  factory QRScanResult.addMenu({
    required String content,
    required bool isUrl,
  }) {
    return QRScanResult(
      type: QRScanType.addMenu,
      content: content,
      isUrl: isUrl,
    );
  }

  /// Convert to map (for navigation)
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (isUrl != null) 'isUrl': isUrl,
    };
  }

  @override
  List<Object?> get props => [type, id, content, isUrl];
}
