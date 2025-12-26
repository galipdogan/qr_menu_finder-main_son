import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Base use case class for clean architecture with Either
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use case with no parameters
abstract class UseCaseNoParams<T> {
  Future<Either<Failure, T>> call();
}

/// Use case for stream operations
abstract class StreamUseCase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}

/// No parameters class
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}