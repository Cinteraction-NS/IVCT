import 'api_error.dart';

class ApiResponse<T> {
  ApiResponse({this.response, this.error});
  T? response;
  ApiError? error;
}
