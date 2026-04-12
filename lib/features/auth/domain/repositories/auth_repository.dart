import '../../data/models/auth_models.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<void> register(RegisterRequest request);
  Future<AuthResponse> verifyOtp(String email, String otpCode);
  Future<bool> resendOtp(String email);
  Future<UserModel> getMe();
  Future<void> logout();
  Future<List<GradeModel>> getGrades();
  Future<void> sendPasswordOtp(String email);
  Future<void> verifyPasswordOtp(String email, String code);
  Future<void> resetPassword(String email, String code, String password, String passwordConfirmation);
}
