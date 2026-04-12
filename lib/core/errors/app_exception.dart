class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({super.message = 'حدث خطأ في الشبكة. تحقق من اتصالك.', super.statusCode});
}

class UnauthorizedException extends AppException {
  UnauthorizedException({super.message = 'غير مصرح. يرجى تسجيل الدخول مجدداً.', super.statusCode = 401});
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;
  ValidationException({required super.message, this.errors, super.statusCode = 422});
}

class ServerException extends AppException {
  ServerException({super.message = 'حدث خطأ في الخادم. حاول مرة أخرى.', super.statusCode = 500});
}
