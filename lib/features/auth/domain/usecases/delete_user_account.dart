import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// UseCase for deleting user account
/// 
/// Follows Clean Architecture - encapsulates business logic
/// WARNING: This is a destructive operation
class DeleteUserAccount implements UseCase<Unit, NoParams> {
  final AuthRepository repository;

  DeleteUserAccount(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await repository.deleteAccount();
  }
}
