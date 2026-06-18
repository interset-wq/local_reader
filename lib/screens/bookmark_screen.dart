import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/book.dart';

class BookmarkScreen extends StatelessWidget {
  final Book book;
  final void Function(Bookmark bookmark) onJumpToBookmark;

  const BookmarkScreen({
    super.key,
    required this.book,
    required this.onJumpToBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('书签'),
      ),
      body: Consumer<AppSettings>(
        builder: (context, settings, _) {
          final currentBook =
              settings.books.firstWhere((b) => b.id == book.id);
          final bookmarks = currentBook.bookmarks;

          if (bookmarks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('暂无书签', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 4),
                  Text('阅读时点击右上角书签图标添加',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bm = bookmarks[index];
              return Dismissible(
                key: Key(bm.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  settings.removeBookmark(book.id, bm.id);
                },
                child: ListTile(
                  leading: const Icon(Icons.bookmark, color: Colors.brown),
                  title: Text(
                    '第${bm.chapterIndex + 1}章',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    bm.preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: Text(
                    _formatDate(bm.createdAt),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  onTap: () => onJumpToBookmark(bm),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
