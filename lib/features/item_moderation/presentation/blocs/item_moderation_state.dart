import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';

/// Base state for item moderation
/// TR: Item moderasyon için temel state
abstract class ItemModerationState extends Equatable {
  const ItemModerationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
/// TR: Başlangıç durumu
class ItemModerationInitial extends ItemModerationState {
  const ItemModerationInitial();
}

/// Loading state (operation in progress)
/// TR: Yükleniyor durumu (işlem devam ediyor)
class ItemModerationLoading extends ItemModerationState {
  final String? message; // Optional loading message / Opsiyonel yükleme mesajı

  const ItemModerationLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Success state (operation completed successfully)
/// TR: Başarılı durumu (işlem başarıyla tamamlandı)
class ItemModerationSuccess extends ItemModerationState {
  final String message;
  final String?
  itemId; // Optional item ID for navigation / Navigasyon için opsiyonel item ID

  const ItemModerationSuccess({required this.message, this.itemId});

  @override
  List<Object?> get props => [message, itemId];
}

/// Error state (operation failed)
/// TR: Hata durumu (işlem başarısız)
class ItemModerationError extends ItemModerationState {
  final Failure failure;
  final String?
  userMessage; // User-friendly error message / Kullanıcı dostu hata mesajı

  const ItemModerationError({required this.failure, this.userMessage});

  @override
  List<Object?> get props => [failure, userMessage];
}

/// Specific success states for different operations
/// TR: Farklı işlemler için özel başarı durumları

class ItemPromotedSuccess extends ItemModerationSuccess {
  const ItemPromotedSuccess({super.itemId})
    : super(message: 'Item successfully promoted to live collection');
}

class ItemApprovedSuccess extends ItemModerationSuccess {
  const ItemApprovedSuccess({required String itemId})
    : super(message: 'Item approved successfully', itemId: itemId);
}

class ItemRejectedSuccess extends ItemModerationSuccess {
  const ItemRejectedSuccess({required String itemId})
    : super(message: 'Item rejected successfully', itemId: itemId);
}

class ItemReportedSuccess extends ItemModerationSuccess {
  const ItemReportedSuccess({required String itemId})
    : super(
        message: 'Item reported successfully. Thank you for your feedback!',
        itemId: itemId,
      );
}
