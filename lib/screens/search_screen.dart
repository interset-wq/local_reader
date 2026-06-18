import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '搜索内容...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onSubmitted: _search,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _search(_controller.text),
          ),
        ],
      ),
      body: !_searched
          ? const Center(child: Text('输入关键词搜索全书内容'))
          : _results.isEmpty
              ? const Center(child: Text('未找到匹配内容'))
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final r = _results[index];
                    return ListTile(
                      dense: true,
                      leading: Text(
                        '第${r.chapterIndex + 1}章',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.brown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      title: Text(
                        r.context,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      onTap: () => widget.onJumpToChapter(r.chapterIndex),
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
