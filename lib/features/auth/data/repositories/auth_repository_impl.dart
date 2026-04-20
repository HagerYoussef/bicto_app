import '../../../../core/services/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final StorageService _storage;

  AuthRepositoryImpl(this._dataSource, this._storage);

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dataSource.login(request);
    final role = response.user.role;
    // CRITICAL: Save role and token immediately to ensure next navigation is role-safe
    await _storage.saveToken(response.accessToken, role: role);
    await _storage.saveRole(role);
    return response;
  }

  @override
  Future<void> register(RegisterRequest request) {
    return _dataSource.register(request);
  }

  @override
  Future<AuthResponse> verifyOtp(String email, String otpCode) async {
    final response = await _dataSource.verifyOtp(email, otpCode);
    // Explicitly NOT saving token here as the flow is verify -> login
    return response;
  }

  @override
  Future<bool> resendOtp(String email) async {
    await _dataSource.resendOtp(email);
    return true;
  }

  @override
  Future<UserModel> getMe() {
    return _dataSource.getMe();
  }

  @override
  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } finally {
      await _storage.clearAll();
    }
  }

  @override
  Future<List<GradeModel>> getGrades() {
    return _dataSource.getGrades();
  }

  @override
  Future<void> sendPasswordOtp(String email) {
    return _dataSource.sendPasswordOtp(email);
  }

  @override
  Future<void> verifyPasswordOtp(String email, String code) {
    return _dataSource.verifyPasswordOtp(email, code);
  }

  @override
  Future<void> resetPassword(String email, String code, String password, String passwordConfirmation) {
    return _dataSource.resetPassword(email, code, password, passwordConfirmation);
  }

  @override
  Future<void> deleteAccount(String password, String confirmation) async {
    try {
      await _dataSource.deleteAccount(password, confirmation);
    } finally {
      await _storage.clearAll();
    }
  }
}
