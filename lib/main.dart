import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/book.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: const LocalReaderApp(),
    ),
  );
}

class AppSettings extends ChangeNotifier {
  double _fontSize = 18.0;
  double _lineHeight = 1.8;
  int _themeMode = 0;
  String _fontFamily = 'serif';
  double _brightness = 1.0;
  int _readingMode = 0;
  List<Book> _books = [];

  double get fontSize => _fontSize;
  double get lineHeight => _lineHeight;
  int get themeMode => _themeMode;
  String get fontFamily => _fontFamily;
  double get brightness => _brightness;
  int get readingMode => _readingMode;
  List<Book> get books => _books;

  ThemeData get currentTheme {
    switch (_themeMode) {
      case 1:
        return AppTheme.darkTheme;
      case 2:
        return AppTheme.sepiaTheme;
      default:
        return AppTheme.lightTheme;
    }
  }

  Future<void> loadAll() async {
    _fontSize = await StorageService.loadFontSize();
    _lineHeight = await StorageService.loadLineHeight();
    _themeMode = await StorageService.loadThemeMode();
    _fontFamily = await StorageService.loadFontFamily();
    _brightness = await StorageService.loadBrightness();
    _readingMode = await StorageService.loadReadingMode();
    _books = await StorageService.loadBooks();
    notifyListeners();
  }

  Future<void> setFontSize(double v) async {
    _fontSize = v;
    await StorageService.saveFontSize(v);
    notifyListeners();
  }

  Future<void> setLineHeight(double v) async {
    _lineHeight = v;
    await StorageService.saveLineHeight(v);
    notifyListeners();
  }

  Future<void> setThemeMode(int v) async {
    _themeMode = v;
    await StorageService.saveThemeMode(v);
    notifyListeners();
  }

  Future<void> setFontFamily(String v) async {
    _fontFamily = v;
    await StorageService.saveFontFamily(v);
    notifyListeners();
  }

  Future<void> setBrightness(double v) async {
    _brightness = v;
    await StorageService.saveBrightness(v);
    notifyListeners();
  }

  Future<void> setReadingMode(int v) async {
    _readingMode = v;
    await StorageService.saveReadingMode(v);
    notifyListeners();
  }

  Future<void> addBook(Book book) async {
    _books.insert(0, book);
    await StorageService.saveBooks(_books);
    notifyListeners();
  }

  Future<void> removeBook(String id) async {
    _books.removeWhere((b) => b.id == id);
    await StorageService.saveBooks(_books);
    notifyListeners();
  }

  Future<void> updateBook(Book book) async {
    final idx = _books.indexWhere((b) => b.id == book.id);
    if (idx >= 0) {
      _books[idx] = book;
      await StorageService.saveBooks(_books);
      notifyListeners();
    }
  }

  Future<void> addBookmark(String bookId, Bookmark bookmark) async {
    final idx = _books.indexWhere((b) => b.id == bookId);
    if (idx >= 0) {
      _books[idx].bookmarks.insert(0, bookmark);
      await StorageService.saveBooks(_books);
      notifyListeners();
    }
  }

  Future<void> removeBookmark(String bookId, String bookmarkId) async {
    final idx = _books.indexWhere((b) => b.id == bookId);
    if (idx >= 0) {
      _books[idx].bookmarks.removeWhere((b) => b.id == bookmarkId);
      await StorageService.saveBooks(_books);
      notifyListeners();
    }
  }
}

class LocalReaderApp extends StatefulWidget {
  const LocalReaderApp({super.key});

  @override
  State<LocalReaderApp> createState() => _LocalReaderAppState();
}

class _LocalReaderAppState extends State<LocalReaderApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<AppSettings>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'Local Reader',
          theme: settings.currentTheme,
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
        );
      },
    );
  }
}
