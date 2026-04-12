import 'package:flutter/material.dart';

class AppConstants {
  static const double borderRadius = 16.0;
  static const double padding = 16.0;
  static const double spacing = 8.0;
  
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Custom Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
