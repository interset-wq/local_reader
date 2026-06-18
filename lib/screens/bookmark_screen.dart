import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';

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
    final mode = Theme.of(context).brightness == Brightness.dark ? 2 : 0;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(mode),
      appBar: AppBar(
        title: Text(
          '书签',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary(mode),
          ),
        ),
      ),
      body: Consumer<AppSettings>(
        builder: (context, settings, _) {
          final currentBook =
              settings.books.firstWhere((b) => b.id == book.id);
          final bookmarks = currentBook.bookmarks;

          if (bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 56,
                    color: AppTheme.textSecondary(mode).withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '暂无书签',
                    style: TextStyle(
                      color: AppTheme.textSecondary(mode),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '阅读时点击书签图标添加',
                    style: TextStyle(
                      color: AppTheme.textSecondary(mode).withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: bookmarks.length,
            separatorBuilder: (_, __) => Divider(
              color: AppTheme.divider(mode),
              height: 1,
              indent: 56,
            ),
            itemBuilder: (context, index) {
              final bm = bookmarks[index];
              return Dismissible(
                key: Key(bm.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red.shade400,
                  child: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 22),
                ),
                onDismissed: (_) {
                  settings.removeBookmark(book.id, bm.id);
                },
                child: InkWell(
                  onTap: () => onJumpToBookmark(bm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.bookmark,
                          size: 18,
                          color: AppTheme.accent(mode),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '第${bm.chapterIndex + 1}章',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary(mode),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bm.preview,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary(mode),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(bm.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary(mode)
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
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
