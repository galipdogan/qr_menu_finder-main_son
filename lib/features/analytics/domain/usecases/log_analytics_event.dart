import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/analytics/domain/repositories/analytics_repository.dart';

class LogAnalyticsEvent implements UseCase<void, LogAnalyticsEventParams> {
  final AnalyticsRepository repository;

  LogAnalyticsEvent(this.repository);

  @override
  Future<Either<Failure, void>> call(LogAnalyticsEventParams params) async {
    return await repository.logEvent(params.name, params.parameters);
  }
}

class LogAnalyticsEventParams extends Equatable {
  final String name;
  final Map<String, dynamic>? parameters;

  const LogAnalyticsEventParams({required this.name, this.parameters});

  @override
  List<Object?> get props => [name, parameters];
}
