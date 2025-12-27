import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// UseCase for sending password reset email
/// 
/// Follows Clean Architecture - encapsulates business logic
class SendPasswordResetEmail implements UseCase<Unit, SendPasswordResetParams> {
  final AuthRepository repository;

  SendPasswordResetEmail(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SendPasswordResetParams params) async {
    return await repository.sendPasswordResetEmail(email: params.email);
  }
}

/// Parameters for password reset email
class SendPasswordResetParams {
  final String email;

  const SendPasswordResetParams({required this.email});
}
