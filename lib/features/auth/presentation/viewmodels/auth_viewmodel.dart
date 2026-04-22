import 'package:flutter/material.dart';
import '../../data/models/auth_models.dart';
import '../../data/models/user_model.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthViewModel(this._repository);

  AuthState _state = AuthState.idle;
  String? _errorMessage;
  UserModel? _currentUser;
  String? _pendingEmail;
  List<GradeModel> _grades = [];

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  String? get pendingEmail => _pendingEmail;
  List<GradeModel> get grades => _grades;
  List<StageModel> get stages {
    final List<StageModel> result = [];
    final Set<int> seenStageIds = {};

    for (final grade in _grades) {
      if (!seenStageIds.contains(grade.stageId)) {
        seenStageIds.add(grade.stageId);
        // Use backend provided stageName if available, otherwise fallback to static logic
        if (grade.stageName != null && grade.stageName!.isNotEmpty) {
          result.add(StageModel(id: grade.stageId, name: grade.stageName!));
        } else {
          result.add(StageModel.fromId(grade.stageId));
        }
      }
    }
    result.sort((a, b) => a.id.compareTo(b.id));
    return result;
  }
  bool get isLoading => _state == AuthState.loading;

  Future<UserModel?> login(String email, String password) async {
    _setState(AuthState.loading);
    try {
      final request = LoginRequest(email: email.trim(), password: password);
      final response = await _repository.login(request);
      _currentUser = response.user;
      _setState(AuthState.success);
      return response.user;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return null;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String gender,
    int? educationalLevel,
    required String password,
    required String passwordConfirmation,
    String? bio,
    String? cvPath,
    String? birthday,
    required String role,
  }) async {
    _setState(AuthState.loading);
    try {
      await _repository.register(RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        email: email.trim(),
        phone: phone,
        gender: gender,
        educationalLevel: educationalLevel,
        password: password,
        passwordConfirmation: passwordConfirmation,
        bio: bio,
        cvPath: cvPath,
        birthday: birthday,
        role: role,
      ));
      _pendingEmail = email.trim();
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    }
  }

  Future<String?> verifyOtp(String otpCode) async {
    if (_pendingEmail == null) return null;
    _setState(AuthState.loading);
    try {
      final response = await _repository.verifyOtp(_pendingEmail!, otpCode);
      _currentUser = response.user;
      _pendingEmail = null;
      _setState(AuthState.success);
      return response.user.role;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return null;
    }
  }

  Future<bool> resendOtp(String email) async {
    _setState(AuthState.loading);
    try {
      await _repository.resendOtp(email);
      _setState(AuthState.idle);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    }
  }

  Future<bool> logout(BuildContext context) async {
    _setState(AuthState.loading);
    try {
      await _repository.logout();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      // Even if API logout fails, local clear occurred in repository finally block
      return true; 
    } finally {
      _currentUser = null;
      _setState(AuthState.idle);
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      _currentUser = await _repository.getMe();
      notifyListeners();
    } catch (_) {}
  }

  void clearError() {
    _errorMessage = null;
    _setState(AuthState.idle);
  }

  Future<void> fetchGrades() async {
    _setState(AuthState.loading);
    try {
      debugPrint('Fetching grades from: ${ApiConstants.baseUrl}${ApiConstants.grades}');
      _grades = await _repository.getGrades();
      debugPrint('Fetched ${_grades.length} grades');
      _setState(AuthState.idle);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
    }
  }

  Future<bool> sendPasswordOtp(String email) async {
    _setState(AuthState.loading);
    try {
      await _repository.sendPasswordOtp(email);
      _setState(AuthState.idle);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    }
  }

  Future<bool> verifyPasswordOtp(String email, String code) async {
    _setState(AuthState.loading);
    try {
      await _repository.verifyPasswordOtp(email, code);
      _setState(AuthState.idle);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    }
  }

  Future<bool> resetPassword(String email, String code, String password, String confirm) async {
    _setState(AuthState.loading);
    try {
      await _repository.resetPassword(email, code, password, confirm);
      _setState(AuthState.idle);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    }
  }

  Future<bool> deleteAccount(String password, String confirmation) async {
    _setState(AuthState.loading);
    try {
      await _repository.deleteAccount(password, confirmation);
      _currentUser = null;
      _setState(AuthState.idle);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    }
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}
