import 'package:dartz/dartz.dart';
import 'package:erp_hr/core/domain/failures/failure.dart';
import 'package:erp_hr/core/storages/local_storages.dart';
import 'package:erp_hr/features/login/data/datasources/login_remote_datasource.dart';
import 'package:erp_hr/features/login/data/models/login_request.dart';
import 'package:erp_hr/features/login/domain/entities/user.dart';
import 'package:erp_hr/features/login/domain/repositories/login_repository.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: LoginRepository)
class LoginRepositoryImpl implements LoginRepository {
  LoginRepositoryImpl(this._remoteDataSource, this._localStorage);

  final LoginRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  @override
  Future<Either<Failure, User>> login({
  required String username,
  required String password,
  required int permissionId,
  }) async {
  final request = LoginRequest(
  userName: username,
  password: password,
  permissionId: permissionId,
  );

  final result = await _remoteDataSource.login(request);

  return result.fold(
  Left.new,
  (response) async {
  await _localStorage.setUserId(
  response.data.result.userProfileId,
  );

  return Right(response.data.result);
  },
  );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // Transmit request to remote API to invalidate backend token FIRST.
    // We must do this before clearing local tokens so the AuthInterceptor has the token to inject.
    final result = await _remoteDataSource.logout();

    // Clear local storage tokens unconditionally, regardless of remote success/failure.
    await _localStorage.clearTokens();

    return result;
  }

  // @override
  // Future<Either<Failure, void>> changePassword({
  //   required String currentPassword,
  //   required String newPassword,
  // }) async {
  //   final token = await _localStorage.getAccessToken();
  //   if (token == null) {
  //     return const Left(
  //       Failure.serverFailure(message: 'Access token not found.'),
  //     );
  //   }
  //   return _remoteDataSource.changePassword(
  //     currentPassword: currentPassword,
  //     newPassword: newPassword,
  //     accessToken: token,
  //   );
  // }
}
