import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/book.dart';
import '../services/parser_service.dart';
import '../theme/app_theme.dart';
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _saveProgress();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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

  void _handleTap(TapDownDetails details) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final x = details.globalPosition.dx;
    final y = details.globalPosition.dy;

    // Top 15% — always toggle toolbar
    if (y < h * 0.15) {
      setState(() => _showToolbar = !_showToolbar);
      return;
    }

    // Bottom 15% — always toggle toolbar
    if (y > h * 0.85) {
      setState(() => _showToolbar = !_showToolbar);
      return;
    }

    // Center band — toggle toolbar
    if (x > w * 0.35 && x < w * 0.65) {
      setState(() => _showToolbar = !_showToolbar);
      return;
    }

    // Left edge — previous chapter
    if (x < w * 0.35) {
      _goToChapter(_currentChapter - 1);
      return;
    }

    // Right edge — next chapter
    if (x > w * 0.65) {
      _goToChapter(_currentChapter + 1);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppTheme.readerBg(0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_chapters.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.readerBg(0),
        body: const Center(child: Text('无法解析此文件')),
      );
    }

    return Consumer<AppSettings>(
      builder: (context, settings, _) {
        final mode = settings.themeMode;
        final readerBg = AppTheme.readerBg(mode);
        final textColor = AppTheme.textPrimary(mode);
        final totalChapters = _chapters.length;
        final progress =
            totalChapters > 0 ? (_currentChapter + 1) / totalChapters : 0.0;

        return Scaffold(
          backgroundColor: readerBg,
          body: GestureDetector(
            onTapDown: _handleTap,
            behavior: HitTestBehavior.translucent,
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
                if (settings.readingMode == 0)
                  _buildPageContent(settings, textColor)
                else
                  _buildScrollContent(settings, textColor),

                // Thin progress line at bottom (always visible, Kindle style)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _ProgressLine(
                    progress: progress,
                    mode: mode,
                    currentChapter: _currentChapter + 1,
                    totalChapters: totalChapters,
                  ),
                ),

                // Top toolbar (Kindle style — minimal)
                if (_showToolbar)
                  _buildTopToolbar(context, settings, mode),

                // Bottom toolbar (Kindle style — Aa + TOC)
                if (_showToolbar)
                  _buildBottomToolbar(context, settings, mode),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageContent(AppSettings settings, Color textColor) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (_) {
        _saveProgress();
      },
      itemBuilder: (context, page) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
          child: Text(
            _chapters[_currentChapter],
            style: TextStyle(
              fontSize: settings.fontSize,
              height: settings.lineHeight,
              fontFamily: settings.fontFamily,
              color: textColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrollContent(AppSettings settings, Color textColor) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(28, 60, 28, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _chapters[_currentChapter],
            style: TextStyle(
              fontSize: settings.fontSize,
              height: settings.lineHeight,
              fontFamily: settings.fontFamily,
              color: textColor,
            ),
          ),
          const SizedBox(height: 32),
          if (_currentChapter < _chapters.length - 1)
            Center(
              child: TextButton.icon(
                onPressed: () => _goToChapter(_currentChapter + 1),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('下一章', style: TextStyle(fontSize: 13)),
              ),
            ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTopToolbar(
      BuildContext context, AppSettings settings, int mode) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg(mode).withValues(alpha: 0.95),
          border: Border(
            bottom: BorderSide(
              color: AppTheme.divider(mode),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios,
                      size: 20, color: AppTheme.textPrimary(mode)),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    widget.book.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary(mode),
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search,
                      size: 20, color: AppTheme.textSecondary(mode)),
                  onPressed: () => _openSearch(context),
                ),
                IconButton(
                  icon: Icon(Icons.bookmark_border,
                      size: 20, color: AppTheme.textSecondary(mode)),
                  onPressed: () => _addBookmark(context, settings),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomToolbar(
      BuildContext context, AppSettings settings, int mode) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg(mode).withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: AppTheme.divider(mode),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chapter slider
                Row(
                  children: [
                    Text(
                      '第${_currentChapter + 1}章',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary(mode),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppTheme.accent(mode),
                          inactiveTrackColor: AppTheme.divider(mode),
                          thumbColor: AppTheme.accent(mode),
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 6),
                          trackHeight: 2,
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 14),
                        ),
                        child: Slider(
                          value: _currentChapter.toDouble(),
                          max: (_chapters.length - 1)
                              .toDouble()
                              .clamp(0, double.infinity),
                          divisions:
                              _chapters.length > 1 ? _chapters.length - 1 : 1,
                          onChanged: (v) => _goToChapter(v.round()),
                        ),
                      ),
                    ),
                    Text(
                      '${_chapters.length}章',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary(mode),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Action buttons — Kindle style
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ToolbarButton(
                      icon: Icons.list,
                      label: '目录',
                      mode: mode,
                      onTap: () => _showChapterList(context, settings),
                    ),
                    _ToolbarButton(
                      icon: Icons.bookmarks_outlined,
                      label: '书签',
                      mode: mode,
                      onTap: () => _openBookmarks(context),
                    ),
                    _ToolbarButton(
                      icon: Icons.text_fields,
                      label: 'Aa',
                      mode: mode,
                      onTap: () => _showAaMenu(context, settings),
                    ),
                    _ToolbarButton(
                      icon: settings.readingMode == 0
                          ? Icons.swap_vert
                          : Icons.view_agenda_outlined,
                      label: settings.readingMode == 0 ? '翻页' : '滚动',
                      mode: mode,
                      onTap: () =>
                          settings.setReadingMode(settings.readingMode == 0 ? 1 : 0),
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

    settings.addBookmark(
      widget.book.id,
      Bookmark(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chapterIndex: _currentChapter,
        charOffset: _currentCharOffset,
        preview: previewText,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('书签已添加'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppTheme.cardBg(settings.themeMode),
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

  void _showChapterList(BuildContext context, AppSettings settings) {
    final mode = settings.themeMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.6,
          decoration: BoxDecoration(
            color: AppTheme.cardBg(mode),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Text(
                      '目录',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary(mode),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_chapters.length}章',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary(mode),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: AppTheme.divider(mode), height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: _chapters.length,
                  itemBuilder: (ctx, i) {
                    final preview = _chapters[i].length > 60
                        ? '${_chapters[i].substring(0, 60)}...'
                        : _chapters[i];
                    final isCurrent = i == _currentChapter;
                    return InkWell(
                      onTap: () {
                        _goToChapter(i);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        color: isCurrent
                            ? AppTheme.accent(mode).withValues(alpha: 0.08)
                            : null,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 32,
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isCurrent
                                      ? AppTheme.accent(mode)
                                      : AppTheme.textSecondary(mode),
                                  fontWeight: isCurrent
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                preview,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isCurrent
                                      ? AppTheme.accent(mode)
                                      : AppTheme.textPrimary(mode),
                                  fontWeight: isCurrent
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  void _showAaMenu(BuildContext context, AppSettings settings) {
    final mode = settings.themeMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: BoxDecoration(
                color: AppTheme.cardBg(mode),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme selector
                  Text(
                    '主题',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary(mode),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ThemeCircle(
                        color: const Color(0xFFF8F8F8),
                        border: true,
                        label: '白',
                        selected: mode == 0,
                        onTap: () {
                          settings.setThemeMode(0);
                          setModalState(() {});
                        },
                      ),
                      _ThemeCircle(
                        color: const Color(0xFFF3EBD8),
                        border: true,
                        label: '纸',
                        selected: mode == 1,
                        onTap: () {
                          settings.setThemeMode(1);
                          setModalState(() {});
                        },
                      ),
                      _ThemeCircle(
                        color: const Color(0xFF2B2B2B),
                        label: '灰',
                        selected: mode == 2,
                        onTap: () {
                          settings.setThemeMode(2);
                          setModalState(() {});
                        },
                      ),
                      _ThemeCircle(
                        color: Colors.black,
                        label: '黑',
                        selected: mode == 3,
                        onTap: () {
                          settings.setThemeMode(3);
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Brightness
                  Row(
                    children: [
                      Icon(Icons.brightness_low,
                          size: 18, color: AppTheme.textSecondary(mode)),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppTheme.accent(mode),
                            inactiveTrackColor: AppTheme.divider(mode),
                            thumbColor: AppTheme.accent(mode),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            trackHeight: 2,
                          ),
                          child: Slider(
                            value: settings.brightness,
                            min: 0.1,
                            max: 1.0,
                            divisions: 9,
                            onChanged: (v) {
                              settings.setBrightness(v);
                              setModalState(() {});
                            },
                          ),
                        ),
                      ),
                      Icon(Icons.brightness_high,
                          size: 18, color: AppTheme.textSecondary(mode)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Font size
                  Row(
                    children: [
                      Text('A',
                          style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary(mode))),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppTheme.accent(mode),
                            inactiveTrackColor: AppTheme.divider(mode),
                            thumbColor: AppTheme.accent(mode),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            trackHeight: 2,
                          ),
                          child: Slider(
                            value: settings.fontSize,
                            min: 14,
                            max: 28,
                            divisions: 14,
                            onChanged: (v) {
                              settings.setFontSize(v);
                              setModalState(() {});
                            },
                          ),
                        ),
                      ),
                      Text('A',
                          style: TextStyle(
                              fontSize: 22,
                              color: AppTheme.textSecondary(mode))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Line height
                  Row(
                    children: [
                      Icon(Icons.format_line_spacing,
                          size: 18, color: AppTheme.textSecondary(mode)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppTheme.accent(mode),
                            inactiveTrackColor: AppTheme.divider(mode),
                            thumbColor: AppTheme.accent(mode),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            trackHeight: 2,
                          ),
                          child: Slider(
                            value: settings.lineHeight,
                            min: 1.2,
                            max: 2.5,
                            divisions: 13,
                            onChanged: (v) {
                              settings.setLineHeight(v);
                              setModalState(() {});
                            },
                          ),
                        ),
                      ),
                      Text(
                        settings.lineHeight.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary(mode),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Font family
                  Row(
                    children: [
                      _FontChip(
                        label: '宋体',
                        selected: settings.fontFamily == 'serif',
                        mode: mode,
                        onTap: () {
                          settings.setFontFamily('serif');
                          setModalState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      _FontChip(
                        label: '黑体',
                        selected: settings.fontFamily == 'sans-serif',
                        mode: mode,
                        onTap: () {
                          settings.setFontFamily('sans-serif');
                          setModalState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      _FontChip(
                        label: '等宽',
                        selected: settings.fontFamily == 'monospace',
                        mode: mode,
                        onTap: () {
                          settings.setFontFamily('monospace');
                          setModalState(() {});
                        },
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
}

// --- Widgets ---

class _ProgressLine extends StatelessWidget {
  final double progress;
  final int mode;
  final int currentChapter;
  final int totalChapters;

  const _ProgressLine({
    required this.progress,
    required this.mode,
    required this.currentChapter,
    required this.totalChapters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      color: AppTheme.readerBg(mode),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Text(
            '$currentChapter/$totalChapters',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary(mode).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.divider(mode).withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.textSecondary(mode).withValues(alpha: 0.4),
                ),
                minHeight: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary(mode).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int mode;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppTheme.textPrimary(mode)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary(mode),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeCircle extends StatelessWidget {
  final Color color;
  final bool border;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCircle({
    required this.color,
    this.border = false,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: border
                  ? Border.all(color: const Color(0xFFCCCCCC), width: 0.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: selected
                ? Icon(
                    Icons.check,
                    size: 20,
                    color: color.computeLuminance() > 0.5
                        ? Colors.black54
                        : Colors.white70,
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary(
                  Theme.of(context).brightness == Brightness.dark ? 2 : 0),
            ),
          ),
        ],
      ),
    );
  }
}

class _FontChip extends StatelessWidget {
  final String label;
  final bool selected;
  final int mode;
  final VoidCallback onTap;

  const _FontChip({
    required this.label,
    required this.selected,
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accent(mode).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.accent(mode) : AppTheme.divider(mode),
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: selected
                ? AppTheme.accent(mode)
                : AppTheme.textPrimary(mode),
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
