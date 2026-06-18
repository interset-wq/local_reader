import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/book.dart';
import '../services/parser_service.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;
  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  List<String> _chapters = [];
  bool _loading = true;
  bool _showToolbar = false;
  late PageController _pageController;
  int _currentChapter = 0;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.book.currentChapter;
    _pageController = PageController(initialPage: _currentChapter);
    _loadBook();
  }

  Future<void> _loadBook() async {
    final parsed = await ParserService.parseFile(
      widget.book.filePath,
      widget.book.fileType,
    );
    setState(() {
      _chapters = parsed.chapters;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _saveProgress();
    super.dispose();
  }

  void _saveProgress() {
    final settings = context.read<AppSettings>();
    widget.book.currentChapter = _currentChapter;
    widget.book.lastRead = DateTime.now();
    settings.updateBookProgress(widget.book);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.book.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_chapters.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.book.title)),
        body: const Center(child: Text('无法解析此文件')),
      );
    }

    return Consumer<AppSettings>(
      builder: (context, settings, _) {
        return Scaffold(
          backgroundColor: settings.currentTheme.scaffoldBackgroundColor,
          body: GestureDetector(
            onTap: () => setState(() => _showToolbar = !_showToolbar),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _chapters.length,
                  onPageChanged: (i) {
                    setState(() => _currentChapter = i);
                    _saveProgress();
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(context, settings, index);
                  },
                ),
                if (_showToolbar) _buildToolbar(context, settings),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPage(BuildContext context, AppSettings settings, int index) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index < _chapters.length)
              Text(
                _chapters[index],
                style: TextStyle(
                  fontSize: settings.fontSize,
                  height: settings.lineHeight,
                  fontFamily: settings.fontFamily,
                  color: settings.themeMode == 1
                      ? Colors.white70
                      : Colors.black87,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, AppSettings settings) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: settings.themeMode == 1
            ? Colors.black87
            : Colors.white.withValues(alpha: 0.95),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '第 ${_currentChapter + 1}/${_chapters.length} 章',
                  style: TextStyle(
                    fontSize: 13,
                    color: settings.themeMode == 1
                        ? Colors.white54
                        : Colors.black54,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.list),
                  onPressed: () => _showChapterList(context, settings),
                  iconSize: 20,
                ),
              ],
            ),
            Slider(
              value: _currentChapter.toDouble(),
              max: (_chapters.length - 1).toDouble(),
              divisions: _chapters.length > 1 ? _chapters.length - 1 : 1,
              onChanged: (v) {
                final page = v.round();
                _pageController.jumpToPage(page);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChapterList(BuildContext context, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.6,
          color: settings.themeMode == 1 ? Colors.grey.shade900 : Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '目录',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: settings.themeMode == 1
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: _chapters.length,
                  itemBuilder: (ctx, i) {
                    final preview = _chapters[i].length > 40
                        ? '${_chapters[i].substring(0, 40)}...'
                        : _chapters[i];
                    return ListTile(
                      title: Text(
                        '第 ${i + 1} 章',
                        style: TextStyle(
                          color: i == _currentChapter
                              ? Colors.brown
                              : (settings.themeMode == 1
                                  ? Colors.white70
                                  : Colors.black87),
                          fontWeight: i == _currentChapter
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: settings.themeMode == 1
                              ? Colors.white38
                              : Colors.black38,
                        ),
                      ),
                      onTap: () {
                        _pageController.jumpToPage(i);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
