import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/compared_price.dart';
import '../../domain/usecases/get_compared_prices.dart';

part 'price_comparison_event.dart';
part 'price_comparison_state.dart';

/// BLoC for managing price comparison state
class PriceComparisonBloc
    extends Bloc<PriceComparisonEvent, PriceComparisonState> {
  final GetComparedPrices getComparedPrices;

  PriceComparisonBloc({required this.getComparedPrices})
    : super(PriceComparisonInitial()) {
    on<PriceComparisonRequested>(_onPriceComparisonRequested);
  }

  /// Handle price comparison request event
  Future<void> _onPriceComparisonRequested(
    PriceComparisonRequested event,
    Emitter<PriceComparisonState> emit,
  ) async {
    emit(PriceComparisonLoading());

    final result = await getComparedPrices(
      GetComparedPricesParams(
        itemName: event.itemName,
        currentRestaurantId: event.currentRestaurantId,
      ),
    );

    result.fold(
      (failure) {
        emit(PriceComparisonError(_mapFailureToMessage(failure)));
      },
      (prices) {
        emit(PriceComparisonLoaded(prices: prices));
      },
    );
  }

  /// Map failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case ServerFailure():
        return 'Sunucu hatası. Fiyatlar alınamadı.';
      case NetworkFailure():
        return 'İnternet bağlantısı yok.';
      default:
        return 'Beklenmedik bir hata oluştu.';
    }
  }
}
