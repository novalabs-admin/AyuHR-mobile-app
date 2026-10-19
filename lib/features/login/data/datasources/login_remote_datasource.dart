import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:erp_hr/core/network/api_client.dart';
import 'package:erp_hr/core/network/api_endpoints.dart';
import 'package:erp_hr/core/storages/local_storages.dart';
import 'package:erp_hr/features/login/data/models/login_request.dart';
import 'package:erp_hr/features/login/data/models/login_response.dart';
import 'package:injectable/injectable.dart';
import 'package:erp_hr/features/login/data/models/user_model.dart';
import 'package:erp_hr/core/domain/failures/failure.dart';

@LazySingleton()
class LoginRemoteDataSource {
  LoginRemoteDataSource(this._apiClient, this._localStorage);
  final ApiClient _apiClient;
  final LocalStorage _localStorage;

  Future<Either<Failure, LoginResponseModel>> login(
      LoginRequest request,
      ) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: request.toJson(),
    );

    return result.fold(
      Left.new,
          (data) {
        try {
          return Right(LoginResponseModel.fromJson(data));
        } catch (e) {
          return const Left(
            Failure.serverFailure(message: 'Failed to parse login response.'),
          );
        }
      },
    );
  }
  Future<Either<Failure, void>> logout() async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.logout,
    );

    return result.fold(
      Left.new,
          (_) => const Right(null),
    );
  }
}
