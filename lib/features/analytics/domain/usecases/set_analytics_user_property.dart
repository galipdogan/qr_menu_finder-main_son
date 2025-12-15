import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/analytics/domain/repositories/analytics_repository.dart';

class SetAnalyticsUserProperty implements UseCase<void, SetAnalyticsUserPropertyParams> {
  final AnalyticsRepository repository;

  SetAnalyticsUserProperty(this.repository);

  @override
  Future<Either<Failure, void>> call(SetAnalyticsUserPropertyParams params) async {
    return await repository.setUserProperty(params.name, params.value);
  }
}

class SetAnalyticsUserPropertyParams extends Equatable {
  final String name;
  final String value;

  const SetAnalyticsUserPropertyParams({required this.name, required this.value});

  @override
  List<Object> get props => [name, value];
}
