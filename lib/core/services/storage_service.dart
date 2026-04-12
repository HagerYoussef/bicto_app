import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _studentTokenKey = 'student_token';
  static const _teacherTokenKey = 'teacher_token';
  static const _roleKey = 'role';

  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Role-Aware Token Management
  String? getToken({String? role}) {
    final activeRole = role ?? getRole();
    if (activeRole == 'student') return _prefs.getString(_studentTokenKey);
    if (activeRole == 'teacher') return _prefs.getString(_teacherTokenKey);
    return null;
  }

  Future<void> saveToken(String token, {String? role}) async {
    final activeRole = role ?? getRole();
    if (activeRole == 'student') {
      await _prefs.setString(_studentTokenKey, token);
    } else if (activeRole == 'teacher') {
      await _prefs.setString(_teacherTokenKey, token);
    }
  }

  String? getValidTokenForPath(String path) {
    if (path.contains('/api/student/')) {
      return _prefs.getString(_studentTokenKey);
    }
    if (path.contains('/api/teacher/')) {
      return _prefs.getString(_teacherTokenKey);
    }
    // For general auth or shared APIs, return the token of the current active role
    return getToken();
  }

  Future<void> clearToken() async {
    await _prefs.remove(_studentTokenKey);
    await _prefs.remove(_teacherTokenKey);
  }

  // Role
  String? getRole() => _prefs.getString(_roleKey);
  Future<void> saveRole(String role) => _prefs.setString(_roleKey, role);

  // Clear all
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  bool get isLoggedIn => getToken() != null;
}
