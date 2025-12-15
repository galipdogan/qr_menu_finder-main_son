import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/notifications/domain/repositories/notification_repository.dart';

class RemoveFCMTokenForUser implements UseCase<void, RemoveFCMTokenParams> {
  final NotificationRepository repository;

  RemoveFCMTokenForUser(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFCMTokenParams params) async {
    return await repository.removeFCMTokenFromFirestore(params.userId, params.token);
  }
}

class RemoveFCMTokenParams extends Equatable {
  final String userId;
  final String? token;

  const RemoveFCMTokenParams({required this.userId, this.token});

  @override
  List<Object?> get props => [userId, token];
}
