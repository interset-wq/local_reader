import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // 0=white, 1=sepia, 2=dark, 3=black (AMOLED)
  static const int white = 0;
  static const int sepia = 1;
  static const int dark = 2;
  static const int black = 3;

  static Color scaffoldBg(int mode) {
    switch (mode) {
      case sepia:
        return const Color(0xFFF5EDDA);
      case dark:
        return const Color(0xFF2B2B2B);
      case black:
        return Colors.black;
      default:
        return const Color(0xFFF8F8F8);
    }
  }

  static Color readerBg(int mode) {
    switch (mode) {
      case sepia:
        return const Color(0xFFF3EBD8);
      case dark:
        return const Color(0xFF1E1E1E);
      case black:
        return Colors.black;
      default:
        return const Color(0xFFFAFAFA);
    }
  }

  static Color textPrimary(int mode) {
    switch (mode) {
      case dark:
        return const Color(0xFFD4D4D4);
      case black:
        return const Color(0xFFCCCCCC);
      default:
        return const Color(0xFF1A1A1A);
    }
  }

  static Color textSecondary(int mode) {
    switch (mode) {
      case dark:
        return const Color(0xFF888888);
      case black:
        return const Color(0xFF777777);
      default:
        return const Color(0xFF666666);
    }
  }

  static Color divider(int mode) {
    switch (mode) {
      case dark:
        return const Color(0xFF3A3A3A);
      case black:
        return const Color(0xFF222222);
      default:
        return const Color(0xFFE0E0E0);
    }
  }

  static Color cardBg(int mode) {
    switch (mode) {
      case dark:
        return const Color(0xFF333333);
      case black:
        return const Color(0xFF111111);
      default:
        return Colors.white;
    }
  }

  static Color accent(int mode) {
    switch (mode) {
      case dark:
      case black:
        return const Color(0xFF90CAF9);
      default:
        return const Color(0xFF2196F3);
    }
  }

  static Brightness systemUiBrightness(int mode) {
    switch (mode) {
      case dark:
      case black:
        return Brightness.dark;
      default:
        return Brightness.light;
    }
  }

  static void setSystemUi(int mode) {
    final isDark = mode == dark || mode == black;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: scaffoldBg(mode),
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));
  }

  static ThemeData buildTheme(int mode) {
    final isDark = mode == dark || mode == black;
    final bg = scaffoldBg(mode);

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      colorSchemeSeed: const Color(0xFF2196F3),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textPrimary(mode),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cardBg(mode),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: DividerThemeData(color: divider(mode), thickness: 0.5),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardBg(mode),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
    );
  }
}
