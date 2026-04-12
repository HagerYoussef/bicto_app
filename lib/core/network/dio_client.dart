import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'auth_interceptor.dart';

class DioClient {
  static Dio? _instance;

  static Dio getInstance() {
    if (_instance == null) {
      _instance = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );
      _instance!.interceptors.add(AuthInterceptor(_instance!));
      _instance!.interceptors.add(ApiLoggingInterceptor());
    }
    return _instance!;
  }
}

class ApiLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('\n🚀 --- API REQUEST --- 🚀');
    debugPrint('➡️ ${options.method} ${options.baseUrl}${options.path}');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('🔢 Query: ${options.queryParameters}');
    }
    if (options.headers.isNotEmpty) {
      debugPrint('🪪 Headers: ${options.headers}');
    }
    if (options.data != null) {
      if (options.data is FormData) {
        final formData = options.data as FormData;
        debugPrint('📦 FormData Fields: ${formData.fields}');
        debugPrint('📦 FormData Files: ${formData.files.map((e) => e.key).toList()}');
      } else {
        try {
          debugPrint('📦 Body: ${jsonEncode(options.data)}');
        } catch (_) {
          debugPrint('📦 Body: ${options.data}');
        }
      }
    }
    debugPrint('------------------------\n');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('\n✅ --- API RESPONSE --- ✅');
    debugPrint('⬅️ ${response.requestOptions.method} ${response.requestOptions.baseUrl}${response.requestOptions.path}');
    debugPrint('🟢 Status: ${response.statusCode}');
    try {
      debugPrint('📦 Data: ${jsonEncode(response.data)}');
    } catch (_) {
      debugPrint('📦 Data: ${response.data}');
    }
    debugPrint('-------------------------\n');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('\n❌ --- API ERROR --- ❌');
    debugPrint('⬅️ ${err.requestOptions.method} ${err.requestOptions.baseUrl}${err.requestOptions.path}');
    debugPrint('🔴 Status Code: ${err.response?.statusCode}');
    debugPrint('🔴 Error Message: ${err.message}');
    debugPrint('🔴 Error Type: ${err.type}');
    debugPrint('🔴 Raw Error: ${err.error}');
    debugPrint('🔴 Exception: ${err.toString()}');
    try {
      if (err.response?.data != null) {
        debugPrint('🔴 Response Data: ${jsonEncode(err.response?.data)}');
      }
    } catch (_) {
      debugPrint('🔴 Response Data: ${err.response?.data}');
    }
    debugPrint('-------------------------\n');
    super.onError(err, handler);
  }
}

