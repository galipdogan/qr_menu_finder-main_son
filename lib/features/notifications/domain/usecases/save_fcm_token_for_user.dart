import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/notifications/domain/repositories/notification_repository.dart';

class SaveFCMTokenForUser implements UseCase<void, SaveFCMTokenParams> {
  final NotificationRepository repository;

  SaveFCMTokenForUser(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveFCMTokenParams params) async {
    return await repository.saveFCMTokenToFirestore(params.userId, params.token);
  }
}

class SaveFCMTokenParams extends Equatable {
  final String userId;
  final String? token;

  const SaveFCMTokenParams({required this.userId, this.token});

  @override
  List<Object?> get props => [userId, token];
}
