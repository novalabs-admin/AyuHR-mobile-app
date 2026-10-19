import 'package:dartz/dartz.dart';
import 'package:erp_hr/core/domain/failures/failure.dart';
import 'package:erp_hr/features/login/domain/entities/user.dart';

abstract class LoginRepository {
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
    required int permissionId,
  });

  Future<Either<Failure, void>> logout();
}