import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../../core/services/storage_service.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authVm = context.read<AuthViewModel>();
    final storage = await StorageService.getInstance();
    
    if (!mounted) return;

    // 1. Immediate Navigation check via SharedPreferences
    String? storedRole = storage.getRole();
    bool hasTeacherToken = storage.getToken(role: 'teacher') != null;
    bool hasStudentToken = storage.getToken(role: 'student') != null;

    if (storage.isLoggedIn || hasTeacherToken || hasStudentToken) {
      // If we have a teacher token but role says student, something is wrong, trust the token
      if (hasTeacherToken && (storedRole == null || storedRole == 'student')) {
        storedRole = 'teacher';
        await storage.saveRole('teacher');
      } else if (hasStudentToken && storedRole == null) {
        storedRole = 'student';
        await storage.saveRole('student');
      }

      if (storedRole == 'teacher') {
        Navigator.pushReplacementNamed(context, '/teacher-dashboard');
      } else if (storedRole == 'student') {
        Navigator.pushReplacementNamed(context, '/student-main');
      } else {
        // Fallback if role is still unknown but we have a token
        Navigator.pushReplacementNamed(context, '/login');
      }
      
      // Load user data in background to refresh UI later
      authVm.loadCurrentUser();
      return;
    }

    // 2. If not logged in locally, try to load from API (maybe session still valid but role cleared)
    // or just go to login if no role is found.
    if (storage.isLoggedIn) {
       await authVm.loadCurrentUser();
       if (!mounted) return;
       
       if (authVm.currentUser != null) {
          if (authVm.currentUser!.role == 'teacher') {
            Navigator.pushReplacementNamed(context, '/teacher-dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/student-main');
          }
          return;
       }
    }

    // Default to login if all else fails
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
