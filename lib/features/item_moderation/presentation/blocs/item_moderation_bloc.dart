import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/approve_item_usecase.dart';
import '../../domain/usecases/promote_to_live_usecase.dart';
import '../../domain/usecases/reject_item_usecase.dart';
import '../../domain/usecases/report_item_usecase.dart';
import 'item_moderation_event.dart';
import 'item_moderation_state.dart';

/// BLoC for item moderation operations
/// TR: Item moderasyon işlemleri için BLoC
/// 
/// This BLoC handles:
/// - Promoting staging items to live collection
/// - Approving/rejecting items (admin only)
/// - Reporting items (user reports)
/// 
/// Bu BLoC şunları yönetir:
/// - Staging item'ları canlı koleksiyona yükseltme
/// - Item'ları onaylama/reddetme (sadece admin)
/// - Item'ları raporlama (kullanıcı raporları)
class ItemModerationBloc
    extends Bloc<ItemModerationEvent, ItemModerationState> {
  final PromoteToLiveUseCase promoteToLiveUseCase;
  final ApproveItemUseCase approveItemUseCase;
  final RejectItemUseCase rejectItemUseCase;
  final ReportItemUseCase reportItemUseCase;

  ItemModerationBloc({
    required this.promoteToLiveUseCase,
    required this.approveItemUseCase,
    required this.rejectItemUseCase,
    required this.reportItemUseCase,
  }) : super(const ItemModerationInitial()) {
    on<PromoteItemToLive>(_onPromoteItemToLive);
    on<ApproveItem>(_onApproveItem);
    on<RejectItem>(_onRejectItem);
    on<ReportItem>(_onReportItem);
  }

  /// Handle promote item to live event
  /// TR: Item'ı canlıya yükseltme event'ini işle
  Future<void> _onPromoteItemToLive(
    PromoteItemToLive event,
    Emitter<ItemModerationState> emit,
  ) async {
    emit(const ItemModerationLoading(
      message: 'Promoting item to live collection...',
    ));

    final result = await promoteToLiveUseCase(event.params);

    result.fold(
      (failure) => emit(ItemModerationError(
        failure: failure,
        userMessage: failure.userMessage,
      )),
      (_) => emit(ItemPromotedSuccess(
        itemId: event.params.itemId,
      )),
    );
  }

  /// Handle approve item event
  /// TR: Item onaylama event'ini işle
  Future<void> _onApproveItem(
    ApproveItem event,
    Emitter<ItemModerationState> emit,
  ) async {
    emit(const ItemModerationLoading(
      message: 'Approving item...',
    ));

    final result = await approveItemUseCase(event.itemId);

    result.fold(
      (failure) => emit(ItemModerationError(
        failure: failure,
        userMessage: failure.userMessage,
      )),
      (_) => emit(ItemApprovedSuccess(itemId: event.itemId)),
    );
  }

  /// Handle reject item event
  /// TR: Item reddetme event'ini işle
  Future<void> _onRejectItem(
    RejectItem event,
    Emitter<ItemModerationState> emit,
  ) async {
    emit(const ItemModerationLoading(
      message: 'Rejecting item...',
    ));

    final result = await rejectItemUseCase(
      RejectItemParams(itemId: event.itemId, reason: event.reason),
    );

    result.fold(
      (failure) => emit(ItemModerationError(
        failure: failure,
        userMessage: failure.userMessage,
      )),
      (_) => emit(ItemRejectedSuccess(itemId: event.itemId)),
    );
  }

  /// Handle report item event
  /// TR: Item raporlama event'ini işle
  Future<void> _onReportItem(
    ReportItem event,
    Emitter<ItemModerationState> emit,
  ) async {
    emit(const ItemModerationLoading(
      message: 'Reporting item...',
    ));

    final result = await reportItemUseCase(event.params);

    result.fold(
      (failure) => emit(ItemModerationError(
        failure: failure,
        userMessage: failure.userMessage,
      )),
      (_) => emit(ItemReportedSuccess(itemId: event.params.itemId)),
    );
  }
}
