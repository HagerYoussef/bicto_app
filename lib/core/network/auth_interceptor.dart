import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../services/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;

  AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final storage = await StorageService.getInstance();
    
    // List of paths that should NOT have the Authorization header
    final publicPaths = [
      ApiConstants.login,
      ApiConstants.loginAlternative,
      ApiConstants.register,
      ApiConstants.verifyOtp,
      ApiConstants.resendOtp,
      ApiConstants.passwordOtp,
      ApiConstants.passwordOtpVerify,
      ApiConstants.passwordReset,
      ApiConstants.grades,
    ];

    if (!publicPaths.any((path) => options.path.contains(path))) {
      final token = storage.getValidTokenForPath(options.path);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    
    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final storage = await StorageService.getInstance();
        final path = err.requestOptions.path;
        final oldToken = storage.getValidTokenForPath(path);
        
        if (oldToken == null) {
          _isRefreshing = false;
          handler.next(err);
          return;
        }

        // Attempt token refresh
        final response = await _dio.post(
          ApiConstants.refresh, // Use relative path for refresh
          options: Options(headers: {
            'Authorization': 'Bearer $oldToken',
            'Accept': 'application/json',
          }),
        );

        final newToken = response.data['access_token'];
        final role = storage.getRole();
        await storage.saveToken(newToken, role: role);

        // Retry original request with new token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';
        
        final retryResponse = await _dio.fetch(opts);
        _isRefreshing = false;
        handler.resolve(retryResponse);
      } catch (e) {
        _isRefreshing = false;
        final storage = await StorageService.getInstance();
        await storage.clearToken(); // Use role-aware clear
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}
