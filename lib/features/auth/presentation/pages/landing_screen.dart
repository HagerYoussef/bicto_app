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
    
    // Wait for the current user to be loaded from storage/API
    await authVm.loadCurrentUser();
    
    if (!mounted) return;

    if (authVm.currentUser == null) {
      // Fallback: Check if we have a stored role and token to stay logged in
      final storedRole = storage.getRole();
      
      if (storedRole != null && storage.isLoggedIn) {
        if (storedRole == 'teacher') {
          Navigator.pushReplacementNamed(context, '/teacher-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/student-main');
        }
        return;
      }

      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // Role-safe navigation based on the user model returned from API
    if (authVm.currentUser!.role == 'teacher') {
      Navigator.pushReplacementNamed(context, '/teacher-dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/student-main');
    }
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
