import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.brown,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFDF5E6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFDF5E6),
          foregroundColor: Color(0xFF3E2723),
          elevation: 0,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.brown,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Color(0xFFE0E0E0),
          elevation: 0,
        ),
      );

  static ThemeData get sepiaTheme => ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.brown,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5E6C8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5E6C8),
          foregroundColor: Color(0xFF3E2723),
          elevation: 0,
        ),
      );
}
