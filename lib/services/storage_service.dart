import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class StorageService {
  static const _booksKey = 'books';
  static const _fontSizeKey = 'font_size';
  static const _lineHeightKey = 'line_height';
  static const _themeKey = 'theme_mode';
  static const _fontFamilyKey = 'font_family';

  static Future<List<Book>> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_booksKey);
    if (json == null) return [];
    return Book.listFromJson(json);
  }

  static Future<void> saveBooks(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_booksKey, Book.listToJson(books));
  }

  static Future<double> loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 18.0;
  }

  static Future<void> saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
  }

  static Future<double> loadLineHeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_lineHeightKey) ?? 1.8;
  }

  static Future<void> saveLineHeight(double height) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lineHeightKey, height);
  }

  static Future<int> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_themeKey) ?? 0;
  }

  static Future<void> saveThemeMode(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode);
  }

  static Future<String> loadFontFamily() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fontFamilyKey) ?? 'serif';
  }

  static Future<void> saveFontFamily(String family) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontFamilyKey, family);
  }
}
