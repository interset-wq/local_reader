import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  final List<String> chapters;
  final void Function(int chapterIndex) onJumpToChapter;

  const SearchScreen({
    super.key,
    required this.chapters,
    required this.onJumpToChapter,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<_SearchResult> _results = [];
  bool _searched = false;

  void _search(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }

    final q = query.toLowerCase();
    final results = <_SearchResult>[];

    for (int i = 0; i < widget.chapters.length; i++) {
      final text = widget.chapters[i].toLowerCase();
      int startIdx = 0;
      while (true) {
        final idx = text.indexOf(q, startIdx);
        if (idx == -1) break;

        final matchStart = (idx - 20).clamp(0, widget.chapters[i].length);
        final matchEnd =
            (idx + q.length + 40).clamp(0, widget.chapters[i].length);
        final contextText = widget.chapters[i].substring(matchStart, matchEnd);

        results.add(_SearchResult(
          chapterIndex: i,
          charOffset: idx,
          context: '...$contextText...',
        ));

        startIdx = idx + 1;
        if (results.length >= 200) break;
      }
      if (results.length >= 200) break;
    }

    setState(() {
      _results = results;
      _searched = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = Theme.of(context).brightness == Brightness.dark ? 2 : 0;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(mode),
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '搜索内容...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: AppTheme.textSecondary(mode),
              fontSize: 15,
            ),
          ),
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textPrimary(mode),
          ),
          onSubmitted: _search,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search,
                color: AppTheme.textSecondary(mode), size: 20),
            onPressed: () => _search(_controller.text),
          ),
        ],
      ),
      body: !_searched
          ? Center(
              child: Text(
                '输入关键词搜索全书内容',
                style: TextStyle(
                  color: AppTheme.textSecondary(mode),
                  fontSize: 14,
                ),
              ),
            )
          : _results.isEmpty
              ? Center(
                  child: Text(
                    '未找到匹配内容',
                    style: TextStyle(
                      color: AppTheme.textSecondary(mode),
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => Divider(
                    color: AppTheme.divider(mode),
                    height: 1,
                    indent: 60,
                  ),
                  itemBuilder: (context, index) {
                    final r = _results[index];
                    return InkWell(
                      onTap: () => widget.onJumpToChapter(r.chapterIndex),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${r.chapterIndex + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary(mode),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                r.context,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textPrimary(mode),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _SearchResult {
  final int chapterIndex;
  final int charOffset;
  final String context;

  _SearchResult({
    required this.chapterIndex,
    required this.charOffset,
    required this.context,
  });
}
