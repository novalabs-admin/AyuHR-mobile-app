import 'package:dio/dio.dart';

/// Interceptor that maps [DioException] to human-readable error messages.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = _mapError(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        error: message,
        type: err.type,
        response: err.response,
      ),
    );
  }

  String _mapError(DioException err) {
    if (err.type == DioExceptionType.badResponse) {
      if (err.response?.data is Map<String, dynamic>) {
        final data = err.response!.data as Map<String, dynamic>;
        if (data.containsKey('description')) {
          return data['description'].toString();
        } else if (data.containsKey('message')) {
          return data['message'].toString();
        }
      }
      return _mapStatusCode(err.response?.statusCode);
    }

    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Connection timed out. Please try again.',
      DioExceptionType.connectionError => 'No internet connection.',
      DioExceptionType.cancel => 'Request was cancelled.',
      _ => 'Something went wrong. Please try again.',
    };
  }

  String _mapStatusCode(int? statusCode) {
    return switch (statusCode) {
      400 => 'Bad request.',
      401 => 'Unauthorized. Please login again.',
      403 => 'Access denied.',
      404 => 'Resource not found.',
      409 => 'Conflict. The resource already exists.',
      422 => 'Invalid data submitted.',
      500 => 'Internal server error.',
      503 => 'Service unavailable. Please try later.',
      _ => 'Server error ($statusCode).',
    };
  }
}
