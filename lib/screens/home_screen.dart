import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/book.dart';
import '../services/file_service.dart';
import '../services/parser_service.dart';
import 'reader_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _sortMode = 0; // 0=recent, 1=title, 2=progress
  String _searchQuery = '';
  bool _showSearch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '搜索书名...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text('我的书架'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) _searchQuery = '';
              });
            },
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.sort),
            onSelected: (v) => setState(() => _sortMode = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 0, child: Text('按最近阅读')),
              const PopupMenuItem(value: 1, child: Text('按书名排序')),
              const PopupMenuItem(value: 2, child: Text('按阅读进度')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppSettings>(
        builder: (context, settings, _) {
          var books = List<Book>.from(settings.books);

          // Filter
          if (_searchQuery.isNotEmpty) {
            books = books
                .where(
                    (b) => b.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();
          }

          // Sort
          switch (_sortMode) {
            case 1:
              books.sort((a, b) => a.title.compareTo(b.title));
            case 2:
              books.sort((a, b) => b.progress.compareTo(a.progress));
            default:
              books.sort((a, b) => b.lastRead.compareTo(a.lastRead));
          }

          if (books.isEmpty && _searchQuery.isEmpty) {
            return _buildEmptyState();
          }

          if (books.isEmpty && _searchQuery.isNotEmpty) {
            return const Center(child: Text('未找到匹配的书籍'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: books.length,
            itemBuilder: (context, index) {
              return _BookListItem(
                book: books[index],
                onTap: () => _openBook(context, books[index]),
                onDelete: () => _deleteBook(context, books[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _importBook(context),
        icon: const Icon(Icons.add),
        label: const Text('导入'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 80, color: Colors.brown.shade200),
          const SizedBox(height: 16),
          Text(
            '书架空空如也',
            style: TextStyle(fontSize: 18, color: Colors.brown.shade300),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮导入 .txt 或 .epub 小说',
            style: TextStyle(fontSize: 14, color: Colors.brown.shade200),
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
        content: Text('确定要删除《${book.title}》吗？\n书签和阅读进度将一并清除。'),
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
      // Delete file from disk
      try {
        final file = File(book.filePath);
        if (await file.exists()) {
          await file.delete();
        }
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
        SnackBar(content: Text('《${parsed.title}》导入成功，共${parsed.chapters.length}章')),
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

class _BookListItem extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  static const _coverColors = [
    Color(0xFF8D6E63), // brown
    Color(0xFF5D4037), // dark brown
    Color(0xFF795548), // medium brown
    Color(0xFF6D4C41), // deep brown
    Color(0xFFA1887F), // light brown
    Color(0xFF4E342E), // very dark brown
  ];

  const _BookListItem({
    required this.book,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final coverColor = _coverColors[book.colorIndex % _coverColors.length];
    final progressPercent = (book.progress * 100).round();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: InkWell(
        onTap: onTap,
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Cover
              Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: coverColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 3,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    book.title.isNotEmpty ? book.title[0] : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.fileType.toUpperCase()} · ${book.totalChapters}章 · $progressPercent%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: book.progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(coverColor),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Last read
              Text(
                _formatLastRead(book.lastRead),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastRead(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${dt.month}/${dt.day}';
  }
}
