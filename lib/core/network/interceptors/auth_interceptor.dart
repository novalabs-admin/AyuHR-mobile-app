import 'package:dio/dio.dart';
import 'package:erp_hr/core/network/api_endpoints.dart';
import 'package:erp_hr/core/network/services/auth_status_service.dart';
import 'package:erp_hr/core/storages/local_storages.dart';


/// Interceptor that injects the auth token into request headers
/// and handles automatic token refresh on 401 responses.
///
/// Uses [LocalStorage] abstraction for token persistence and
/// relative [ApiEndpoints] paths (base URL comes from Dio config).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._localStorage, this._dio, this._authStatusService);
  final LocalStorage _localStorage;
  final Dio _dio;
  final AuthStatusService _authStatusService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _localStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    try {
      final refreshToken = await _localStorage.getRefreshToken();
      if (refreshToken == null) {
        return handler.next(err);
      }

      // Use a fresh Dio instance with the same base URL to prevent
      // infinite interceptor loops.
      final refreshDio = Dio(
        BaseOptions(baseUrl: _dio.options.baseUrl),
      );

      final response = await refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.data == null) {
        throw Exception('Invalid refresh response');
      }

      final data = response.data!;
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String;

      // Persist new tokens
      await _localStorage.setAccessToken(newAccessToken);
      await _localStorage.setRefreshToken(newRefreshToken);

      // Retry the original request with the new token
      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      final retryResponse =
          await _dio.fetch<Map<String, dynamic>>(requestOptions);
      return handler.resolve(retryResponse);
    } catch (_) {
      // Refresh failed — clear tokens, notify app to logout with a reason, and let error propagate
      await _localStorage.clearTokens();
      _authStatusService.notifyLogout('Session expired. Please log in again.');
      return handler.next(err);
    }
  }
}
