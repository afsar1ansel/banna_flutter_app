import 'package:flutter/material.dart';

class AppColors {
  // Banna premium forest-green brand palette
  static const Color background = Color(0xFFF8F6F1);
  static const Color foreground = Color(0xFF1C1C1C);
  static const Color card = Color(0xFFFFFFFF);
  
  static const Color primary = Color(0xFF3FAE5A);
  static const Color primaryHover = Color(0xFF35944C);
  
  static const Color secondary = Color(0xFFF2EFE9);
  static const Color border = Color(0xFFE8E4D8);
  static const Color muted = Color(0xFF6D6D6D);
  
  static const Color forestGreen = Color(0xFF1F3A2E);
  static const Color forestGreenLight = Color(0xFF2D5241);
  
  static const Color activeAmber = Color(0xFFD9A441);
  static const Color errorRed = Color(0xFFEF4444);
  
  // Custom dashboard colors from screenshots
  static const Color cardPeach = Color(0xFFFFF6F0);
  static const Color cardLightBlue = Color(0xFFEBF3FC);
  static const Color orangeButton = Color(0xFFEE7423);
  static const Color cardPurple = Color(0xFF7D58EC);
}

class AppConstants {
  // Set to local host for emulators (Android emulator redirects 10.0.2.2 to computer's localhost)
  // iOS simulator can directly use 127.0.0.1
  static const String baseApiUrlAndroid = 'http://10.0.2.2:8000';
  static const String baseApiUrlIos = 'http://127.0.0.1:8000';
  
  // Default values
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
}
