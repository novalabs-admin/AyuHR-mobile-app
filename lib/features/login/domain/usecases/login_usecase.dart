import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_hr/core/domain/failures/failure.dart';
import 'package:erp_hr/core/domain/usecases/use_case.dart';
import 'package:erp_hr/features/login/domain/entities/user.dart';
import 'package:erp_hr/features/login/domain/repositories/login_repository.dart';
import 'package:injectable/injectable.dart';

class LoginParams extends Equatable {
  const LoginParams({required this.username, required this.password,});
  final String username;
  final String password;

  @override
  List<Object?> get props => [username, password];
}

@lazySingleton
class LoginUseCase extends UseCase<User, LoginParams> {
  LoginUseCase(this._repository);

  final LoginRepository _repository;

  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    return _repository.login(
      username: params.username,
      password: params.password,
      permissionId: 0,
    );
  }
}
