import 'package:dio/dio.dart';
import 'package:erp_hr/core/config/env_config.dart';
import 'package:erp_hr/core/network/api_client.dart';
import 'package:erp_hr/core/network/interceptors/auth_interceptor.dart';
import 'package:erp_hr/core/network/interceptors/error_interceptor.dart';
import 'package:erp_hr/core/network/interceptors/logging_interceptor.dart';
import 'package:erp_hr/core/network/services/auth_status_service.dart';
import 'package:erp_hr/core/storages/local_storages.dart';
import 'package:injectable/injectable.dart';


/// DI module that registers [Dio] and [ApiClient] as singletons.
@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(LocalStorage localStorage, AuthStatusService authStatusService) {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.instance.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(localStorage, dio, authStatusService),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);

    return dio;
  }

  @lazySingleton
  ApiClient apiClient(Dio dio) => ApiClient(dio);

  @Named('rating_engine')
  @lazySingleton
  Dio ratingEngineDio(
      LocalStorage localStorage, AuthStatusService authStatusService) {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.instance.ratingEngineBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(localStorage, dio, authStatusService),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);

    return dio;
  }

  @Named('rating_engine')
  @lazySingleton
  ApiClient ratingEngineApiClient(@Named('rating_engine') Dio dio) =>
      ApiClient(dio);
}
