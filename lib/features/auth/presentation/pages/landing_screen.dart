import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

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
    
    // Wait for the current user to be loaded from storage/API
    await authVm.loadCurrentUser();
    
    if (!mounted) return;

    if (authVm.currentUser == null) {
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

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
