import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/book.dart';
import '../services/parser_service.dart';
import 'search_screen.dart';
import 'bookmark_screen.dart';

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
  int _currentChapter = 0;
  int _currentCharOffset = 0;

  late PageController _pageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.book.currentChapter;
    _currentCharOffset = widget.book.currentCharOffset;
    _pageController = PageController();
    _scrollController = ScrollController();
    _loadBook();
  }

  Future<void> _loadBook() async {
    final parsed = await ParserService.parseFile(
      widget.book.filePath,
      widget.book.fileType,
    );
    setState(() {
      _chapters = parsed.chapters;
      widget.book.totalChapters = _chapters.length;
      _loading = false;
    });
    _paginateCurrentChapter();
  }

  void _paginateCurrentChapter() {
    if (_chapters.isEmpty) return;
    // We paginate on-demand per chapter using LayoutBuilder in the page builder
    // For now just ensure page controller is at the right position
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _saveProgress();
    super.dispose();
  }

  void _saveProgress() {
    final settings = context.read<AppSettings>();
    widget.book.currentChapter = _currentChapter;
    widget.book.currentCharOffset = _currentCharOffset;
    widget.book.lastRead = DateTime.now();
    settings.updateBook(widget.book);
  }

  void _goToChapter(int index) {
    if (index < 0 || index >= _chapters.length) return;
    setState(() {
      _currentChapter = index;
      _currentCharOffset = 0;
    });
    if (context.read<AppSettings>().readingMode == 0) {
      _pageController.jumpToPage(0);
    } else {
      _scrollController.jumpTo(0);
    }
    _saveProgress();
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
        final isDark = settings.themeMode == 1;
        final bgColor = settings.currentTheme.scaffoldBackgroundColor;

        return Scaffold(
          backgroundColor: bgColor,
          body: GestureDetector(
            onTap: () => setState(() => _showToolbar = !_showToolbar),
            child: Stack(
              children: [
                // Brightness overlay
                if (settings.brightness < 1.0)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.black
                            .withValues(alpha: 1.0 - settings.brightness),
                      ),
                    ),
                  ),
                // Content
                settings.readingMode == 0
                    ? _buildPageMode(context, settings)
                    : _buildScrollMode(context, settings),
                // Top bar
                if (_showToolbar) _buildTopBar(context, settings, isDark),
                // Bottom bar
                if (_showToolbar) _buildBottomBar(context, settings, isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageMode(BuildContext context, AppSettings settings) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (page) {
        setState(() {
          _currentCharOffset = 0;
        });
        _saveProgress();
      },
      itemBuilder: (context, page) {
        return _ChapterPage(
          text: _chapters[_currentChapter],
          fontSize: settings.fontSize,
          lineHeight: settings.lineHeight,
          fontFamily: settings.fontFamily,
          isDark: settings.themeMode == 1,
          onNextChapter: () => _goToChapter(_currentChapter + 1),
          onPrevChapter: () => _goToChapter(_currentChapter - 1),
        );
      },
    );
  }

  Widget _buildScrollMode(BuildContext context, AppSettings settings) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _chapters[_currentChapter],
            style: TextStyle(
              fontSize: settings.fontSize,
              height: settings.lineHeight,
              fontFamily: settings.fontFamily,
              color: settings.themeMode == 1 ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 32),
          if (_currentChapter < _chapters.length - 1)
            Center(
              child: TextButton.icon(
                onPressed: () => _goToChapter(_currentChapter + 1),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('下一章'),
              ),
            ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        ],
      ),
    );
  }

  Widget _buildTopBar(
      BuildContext context, AppSettings settings, bool isDark) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black87 : Colors.white.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  iconSize: 22,
                ),
                Expanded(
                  child: Text(
                    widget.book.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () => _addBookmark(context, settings),
                  iconSize: 22,
                  tooltip: '添加书签',
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _openSearch(context),
                  iconSize: 22,
                  tooltip: '搜索',
                ),
                IconButton(
                  icon: const Icon(Icons.bookmarks_outlined),
                  onPressed: () => _openBookmarks(context),
                  iconSize: 22,
                  tooltip: '书签列表',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, AppSettings settings, bool isDark) {
    final textColor = isDark ? Colors.white70 : Colors.black54;
    final totalChapters = _chapters.length;
    final progress =
        totalChapters > 0 ? (_currentChapter + 1) / totalChapters : 0.0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black87 : Colors.white.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chapter slider
                Row(
                  children: [
                    Text(
                      '第 ${_currentChapter + 1}/$totalChapters 章',
                      style: TextStyle(fontSize: 12, color: textColor),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Slider(
                        value: _currentChapter.toDouble(),
                        max: (totalChapters - 1).toDouble().clamp(0, double.infinity),
                        divisions:
                            totalChapters > 1 ? totalChapters - 1 : 1,
                        onChanged: (v) {
                          _goToChapter(v.round());
                        },
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                // Action row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _BottomAction(
                      icon: settings.readingMode == 0
                          ? Icons.swap_vert
                          : Icons.swap_horiz,
                      label: settings.readingMode == 0 ? '翻页' : '滚动',
                      onTap: () {
                        settings.setReadingMode(
                            settings.readingMode == 0 ? 1 : 0);
                      },
                    ),
                    _BottomAction(
                      icon: Icons.wb_sunny_outlined,
                      label: '亮度',
                      onTap: () => _showBrightnessSlider(context, settings),
                    ),
                    _BottomAction(
                      icon: Icons.text_fields,
                      label: '字体',
                      onTap: () => _showFontSettings(context, settings),
                    ),
                    _BottomAction(
                      icon: Icons.list,
                      label: '目录',
                      onTap: () => _showChapterList(context, settings),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addBookmark(BuildContext context, AppSettings settings) {
    final preview = _chapters[_currentChapter];
    final previewText =
        preview.length > 50 ? '${preview.substring(0, 50)}...' : preview;

    final bookmark = Bookmark(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chapterIndex: _currentChapter,
      charOffset: _currentCharOffset,
      preview: previewText,
    );

    settings.addBookmark(widget.book.id, bookmark);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('书签已添加'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _openSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          chapters: _chapters,
          onJumpToChapter: (index) {
            Navigator.pop(context);
            _goToChapter(index);
          },
        ),
      ),
    );
  }

  void _openBookmarks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookmarkScreen(
          book: widget.book,
          onJumpToBookmark: (bookmark) {
            Navigator.pop(context);
            _goToChapter(bookmark.chapterIndex);
          },
        ),
      ),
    );
  }

  void _showBrightnessSlider(BuildContext context, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Row(
            children: [
              const Icon(Icons.brightness_low, size: 20),
              Expanded(
                child: Slider(
                  value: settings.brightness,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  onChanged: (v) => settings.setBrightness(v),
                ),
              ),
              const Icon(Icons.brightness_high, size: 20),
            ],
          ),
        );
      },
    );
  }

  void _showFontSettings(BuildContext context, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('字体大小',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('${settings.fontSize.round()}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Slider(
                    value: settings.fontSize,
                    min: 14,
                    max: 28,
                    divisions: 14,
                    onChanged: (v) {
                      settings.setFontSize(v);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('行高',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(settings.lineHeight.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Slider(
                    value: settings.lineHeight,
                    min: 1.2,
                    max: 2.5,
                    divisions: 13,
                    onChanged: (v) {
                      settings.setLineHeight(v);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('字体',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 16),
                      ChoiceChip(
                        label: const Text('宋体'),
                        selected: settings.fontFamily == 'serif',
                        onSelected: (_) => settings.setFontFamily('serif'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('黑体'),
                        selected: settings.fontFamily == 'sans-serif',
                        onSelected: (_) =>
                            settings.setFontFamily('sans-serif'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('等宽'),
                        selected: settings.fontFamily == 'monospace',
                        onSelected: (_) =>
                            settings.setFontFamily('monospace'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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
                  '目录 (${_chapters.length}章)',
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
                    final preview = _chapters[i].length > 60
                        ? '${_chapters[i].substring(0, 60)}...'
                        : _chapters[i];
                    return ListTile(
                      dense: true,
                      leading: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: i == _currentChapter
                              ? Colors.brown
                              : Colors.grey,
                          fontWeight: i == _currentChapter
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      title: Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
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
                      onTap: () {
                        _goToChapter(i);
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

class _ChapterPage extends StatelessWidget {
  final String text;
  final double fontSize;
  final double lineHeight;
  final String fontFamily;
  final bool isDark;
  final VoidCallback onNextChapter;
  final VoidCallback onPrevChapter;

  const _ChapterPage({
    required this.text,
    required this.fontSize,
    required this.lineHeight,
    required this.fontFamily,
    required this.isDark,
    required this.onNextChapter,
    required this.onPrevChapter,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: (details) {
        final w = MediaQuery.of(context).size.width;
        final x = details.globalPosition.dx;
        if (x < w * 0.3) {
          onPrevChapter();
        } else if (x > w * 0.7) {
          onNextChapter();
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
        physics: const NeverScrollableScrollPhysics(),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            height: lineHeight,
            fontFamily: fontFamily,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
