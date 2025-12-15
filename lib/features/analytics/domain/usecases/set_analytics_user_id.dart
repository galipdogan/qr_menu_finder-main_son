import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/analytics/domain/repositories/analytics_repository.dart';

class SetAnalyticsUserId implements UseCase<void, SetAnalyticsUserIdParams> {
  final AnalyticsRepository repository;

  SetAnalyticsUserId(this.repository);

  @override
  Future<Either<Failure, void>> call(SetAnalyticsUserIdParams params) async {
    return await repository.setUserId(params.id);
  }
}

class SetAnalyticsUserIdParams extends Equatable {
  final String? id;

  const SetAnalyticsUserIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}
