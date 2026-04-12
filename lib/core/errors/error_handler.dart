import 'package:dio/dio.dart';
import '../errors/app_exception.dart';

class ErrorHandler {
  static AppException handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return NetworkException(message: 'انتهت مهلة الاتصال. حاول مرة أخرى.');
        case DioExceptionType.connectionError:
          return NetworkException();
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          switch (statusCode) {
            case 401:
              return UnauthorizedException();
            case 422:
              final message = data?['message'] ?? 'بيانات غير صحيحة.';
              final errors = _extractErrors(data?['errors']);
              return ValidationException(message: message, errors: errors, statusCode: 422);
            case 403:
              return AppException(message: 'ليس لديك صلاحية للوصول.', statusCode: 403);
            case 404:
              return AppException(message: 'المورد المطلوب غير موجود.', statusCode: 404);
            case 500:
            default:
              final message = data?['message'] ?? 'حدث خطأ غير متوقع.';
              return ServerException(message: message, statusCode: statusCode);
          }
        default:
          return AppException(message: 'حدث خطأ غير متوقع. حاول مرة أخرى.');
      }
    }
    return AppException(message: error.toString());
  }

  static Map<String, List<String>>? _extractErrors(dynamic errors) {
    if (errors == null) return null;
    if (errors is Map) {
      return errors.map((key, value) {
        if (value is List) {
          return MapEntry(key.toString(), value.map((e) => e.toString()).toList());
        }
        return MapEntry(key.toString(), [value.toString()]);
      });
    }
    return null;
  }
}
