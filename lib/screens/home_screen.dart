import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/book.dart';
import '../services/file_service.dart';
import '../services/parser_service.dart';
import '../theme/app_theme.dart';
import 'reader_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSearch = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, _) {
        final mode = settings.themeMode;
        AppTheme.setSystemUi(mode);

        var books = List<Book>.from(settings.books);
        books.sort((a, b) => b.lastRead.compareTo(a.lastRead));

        final filteredBooks = _searchQuery.isNotEmpty
            ? books
                .where((b) =>
                    b.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList()
            : books;

        final recentlyRead = filteredBooks
            .where((b) => b.progress > 0)
            .toList();
        final allBooks = filteredBooks;

        return Scaffold(
          backgroundColor: AppTheme.scaffoldBg(mode),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, settings, mode),
                if (_showSearch) _buildSearchBar(mode),
                Expanded(
                  child: allBooks.isEmpty
                      ? _buildEmptyState(mode)
                      : CustomScrollView(
                          slivers: [
                            if (recentlyRead.isNotEmpty && _searchQuery.isEmpty)
                              SliverToBoxAdapter(
                                child: _buildContinueReading(
                                    context, recentlyRead.first, mode),
                              ),
                            if (_searchQuery.isEmpty)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 16, 20, 8),
                                  child: Text(
                                    '全部书籍',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textSecondary(mode),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.6,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 16,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return _BookCoverCard(
                                      book: allBooks[index],
                                      mode: mode,
                                      onTap: () => _openBook(
                                          context, allBooks[index]),
                                      onLongPress: () => _deleteBook(
                                          context, allBooks[index]),
                                    );
                                  },
                                  childCount: allBooks.length,
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 80)),
                          ],
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _importBook(context),
            backgroundColor: AppTheme.accent(mode),
            foregroundColor: Colors.white,
            elevation: 2,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, AppSettings settings, int mode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: _showSearch
                ? const SizedBox.shrink()
                : Text(
                    '书架',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary(mode),
                    ),
                  ),
          ),
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              color: AppTheme.textSecondary(mode),
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) _searchQuery = '';
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: AppTheme.textSecondary(mode),
              size: 22,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(int mode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.cardBg(mode),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.divider(mode)),
        ),
        child: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: '搜索书名...',
            hintStyle: TextStyle(
              color: AppTheme.textSecondary(mode),
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.search,
                size: 18, color: AppTheme.textSecondary(mode)),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textPrimary(mode),
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
      ),
    );
  }

  Widget _buildContinueReading(
      BuildContext context, Book book, int mode) {
    final coverColors = _BookCoverCard.coverColors;
    final coverColor = coverColors[book.colorIndex % coverColors.length];
    final progressPercent = (book.progress * 100).round();

    return GestureDetector(
      onTap: () => _openBook(context, book),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(mode),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider(mode), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 76,
              decoration: BoxDecoration(
                color: coverColor,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  book.title.isNotEmpty ? book.title[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary(mode),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '第${book.currentChapter + 1}章 · 已读$progressPercent%',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary(mode),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: book.progress,
                      backgroundColor: AppTheme.divider(mode),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.accent(mode)),
                      minHeight: 3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.play_circle_outline,
              color: AppTheme.accent(mode),
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(int mode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 72,
            color: AppTheme.textSecondary(mode).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '书架空空如也',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary(mode),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击 + 按钮导入 .txt 或 .epub 小说',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary(mode).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _openBook(BuildContext context, Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReaderScreen(book: book)),
    );
  }

  Future<void> _deleteBook(BuildContext context, Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除书籍'),
        content: Text('确定要删除《${book.title}》吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final file = File(book.filePath);
        if (await file.exists()) await file.delete();
      } catch (_) {}
      if (context.mounted) {
        context.read<AppSettings>().removeBook(book.id);
      }
    }
  }

  Future<void> _importBook(BuildContext context) async {
    final file = await FileService.pickFile();
    if (file == null) return;

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在导入...')),
    );

    try {
      final destPath = await FileService.copyToAppDir(file);
      final fileType = file.extension?.toLowerCase() ?? 'txt';
      final parsed = await ParserService.parseFile(destPath, fileType);

      final book = Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: parsed.title,
        filePath: destPath,
        fileType: fileType,
        totalChapters: parsed.chapters.length,
        colorIndex: DateTime.now().millisecond % 6,
      );

      if (!context.mounted) return;
      await context.read<AppSettings>().addBook(book);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('《${parsed.title}》导入成功')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败: $e')),
      );
    }
  }
}

class _BookCoverCard extends StatelessWidget {
  final Book book;
  final int mode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  static const coverColors = [
    Color(0xFF6D4C41),
    Color(0xFF5D4037),
    Color(0xFF795548),
    Color(0xFF8D6E63),
    Color(0xFF4E342E),
    Color(0xFF3E2723),
  ];

  const _BookCoverCard({
    required this.book,
    required this.mode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final coverColor = coverColors[book.colorIndex % coverColors.length];
    final progressPercent = (book.progress * 100).round();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: coverColor,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Spine effect
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          bottomLeft: Radius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  // Title
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Text(
                        book.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 2,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Progress badge
                  if (book.progress > 0)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$progressPercent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textPrimary(mode),
            ),
          ),
        ],
      ),
    );
  }
}
