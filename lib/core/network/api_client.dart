import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:erp_hr/core/domain/failures/failure.dart';
import 'package:injectable/injectable.dart';


/// Centralized HTTP client wrapping [Dio].
///
/// Usage:
/// ```dart
/// final result = await apiClient.get<Map<String, dynamic>>('/users/1');
/// result.fold(
///   (failure) => print(failure.message),
///   (data) => print(data),
/// );
/// ```

class ApiClient {
  ApiClient(this._dio);
  final Dio _dio;

  /// GET request returning `Either<Failure, T>`.
  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
      ),
    );
  }

  /// POST request returning `Either<Failure, T>`.
  Future<Either<Failure, T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _request(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
    );
  }

  /// PUT request returning `Either<Failure, T>`.
  Future<Either<Failure, T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      () => _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
    );
  }

  /// DELETE request returning `Either<Failure, T>`.
  Future<Either<Failure, T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      () => _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
    );
  }

  /// PATCH request returning `Either<Failure, T>`.
  Future<Either<Failure, T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      () => _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
    );
  }

  Future<Either<Failure, T>> _request<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      final response = await request();
      return Right(response.data as T);
    } on DioException catch (e) {
      String errorMessage = 'Unexpected error occurred.';

      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        
        // Try various common error fields
        final description = data['description']?.toString();
        final errorDescription = (data['error'] is Map) 
            ? data['error']['description']?.toString() 
            : null;
        final message = data['message']?.toString();
        final errors = data['errors'];

        if (errorDescription != null && errorDescription.isNotEmpty) {
          errorMessage = errorDescription;
        } else if (description != null && description.isNotEmpty) {
          errorMessage = description;
        } else if (message != null && message.isNotEmpty) {
          errorMessage = message;
        }

        if (errors is List && errors.isNotEmpty) {
          errorMessage += '\n${errors.join('\n')}';
        } else if (errors != null && errors is! Map) {
          errorMessage += '\n$errors';
        }
      } else {
        errorMessage = e.message ?? errorMessage;
      }

      return Left(
        Failure.serverFailure(message: errorMessage),
      );
    } catch (e) {
      return Left(
        Failure.serverFailure(message: e.toString()),
      );
    }
  }
}
