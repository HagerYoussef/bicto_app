import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(LoginRequest request);
  Future<void> register(RegisterRequest request);
  Future<AuthResponse> verifyOtp(String email, String otpCode);
  Future<void> resendOtp(String email);
  Future<UserModel> getMe();
  Future<void> logout();
  Future<List<GradeModel>> getGrades();
  Future<void> sendPasswordOtp(String email);
  Future<void> verifyPasswordOtp(String email, String code);
  Future<void> resetPassword(String email, String code, String password, String passwordConfirmation);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final _dio = DioClient.getInstance();

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      try {
        final response = await _dio.post(ApiConstants.login, data: request.toJson());
        return AuthResponse.fromJson(response.data);
      } on DioException catch (e) {
        // Fallback to alternative login path if the first one fails with 404 or 405
        if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
          final response = await _dio.post(ApiConstants.loginAlternative, data: request.toJson());
          return AuthResponse.fromJson(response.data);
        }
        rethrow;
      }
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> register(RegisterRequest request) async {
    try {
      dynamic data;
      if (request.cvPath != null) {
        data = FormData.fromMap({
          ...request.toJson(),
          'cv': await MultipartFile.fromFile(request.cvPath!),
        });
      } else {
        data = request.toJson();
      }
      
      final endpoint = request.role == 'teacher' ? ApiConstants.teacherRegister : ApiConstants.register;
      await _dio.post(endpoint, data: data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<AuthResponse> verifyOtp(String email, String otpCode) async {
    try {
      final response = await _dio.post(ApiConstants.verifyOtp, data: {
        'email': email,
        'otp_code': otpCode,
      });
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> resendOtp(String email) async {
    try {
      await _dio.post(ApiConstants.resendOtp, data: {'email': email});
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      return UserModel.fromJson(response.data['user'] ?? response.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<GradeModel>> getGrades() async {
    try {
      final response = await _dio.get(ApiConstants.grades);
      final dynamic data = response.data;
      final List<dynamic> list = (data is Map) ? (data['data'] ?? []) : (data is List ? data : []);
      return list.map((e) => GradeModel.fromJson(e)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> sendPasswordOtp(String email) async {
    try {
      await _dio.post(ApiConstants.passwordOtp, data: {'email': email});
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> verifyPasswordOtp(String email, String code) async {
    try {
      await _dio.post(ApiConstants.passwordOtpVerify, data: {
        'email': email,
        'otp_code': code,
      });
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> resetPassword(String email, String code, String password, String passwordConfirmation) async {
    try {
      await _dio.post(ApiConstants.passwordReset, data: {
        'email': email,
        'otp_code': code,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
