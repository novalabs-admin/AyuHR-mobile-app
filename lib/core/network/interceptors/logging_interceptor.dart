import 'package:dio/dio.dart';
import 'package:erp_hr/core/config/env_config.dart';


/// Interceptor that logs HTTP requests and responses.
///
/// Only logs when `EnvConfig.instance.enableLogging` is `true`.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (EnvConfig.instance.enableLogging) {
      // ignore: avoid_print
      print('→ ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (EnvConfig.instance.enableLogging) {
      // ignore: avoid_print
      print('← ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (EnvConfig.instance.enableLogging) {
      // ignore: avoid_print
      print('✖ ${err.type} ${err.requestOptions.uri} — ${err.message}');
    }
    handler.next(err);
  }
}
