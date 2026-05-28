import 'package:cinteraction_vc/layers/domain/entities/api_error.dart';
import 'package:dio/dio.dart';

class ApiErrorDto extends ApiError {
  final Map<String, dynamic>? errors;

  ApiErrorDto({
    required super.errorCode,
    required super.errorMessage,
    this.errors,
  });

  factory ApiErrorDto.fromDioException(DioException exception) {
    final data = exception.response?.data ?? {};

    return ApiErrorDto(
      errorCode: exception.response?.statusCode ?? 0,
      errorMessage: data['message'] ?? exception.message ?? 'Unknown error',
      errors: data['errors'] as Map<String, dynamic>?,
    );
  }

  factory ApiErrorDto.fromDioResponse(Response response) {
    final data = response.data ?? {};

    return ApiErrorDto(
      errorCode: response.statusCode ?? 0,
      errorMessage: data['message'] ?? 'Unknown error',
      errors: data['errors'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return errorMessage;
  }
}
