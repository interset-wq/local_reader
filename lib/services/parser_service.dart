import 'dart:io';
import 'package:epubx/epubx.dart' as epubx;

class ParsedBook {
  final String title;
  final List<String> chapters;

  ParsedBook({required this.title, required this.chapters});
}

class ParserService {
  static Future<ParsedBook> parseFile(String filePath, String fileType) async {
    if (fileType == 'epub') {
      return _parseEpub(filePath);
    }
    return _parseTxt(filePath);
  }

  static Future<ParsedBook> _parseTxt(String filePath) async {
    final content = await File(filePath).readAsString();
    final title = filePath.split('/').last.replaceAll('.txt', '');

    final chapters = _splitTxtChapters(content);
    return ParsedBook(title: title, chapters: chapters);
  }

  static List<String> _splitTxtChapters(String content) {
    final chapterPattern = RegExp(
      r'^(第[零一二三四五六七八九十百千万\d]+[章节回卷]|Chapter\s+\d+)',
      multiLine: true,
    );

    final matches = chapterPattern.allMatches(content).toList();

    if (matches.length < 2) {
      return _splitByLength(content, 3000);
    }

    final chapters = <String>[];
    for (int i = 0; i < matches.length; i++) {
      final start = matches[i].start;
      final end = i + 1 < matches.length ? matches[i + 1].start : content.length;
      final chapter = content.substring(start, end).trim();
      if (chapter.isNotEmpty) {
        chapters.add(chapter);
      }
    }

    if (chapters.isEmpty) {
      return _splitByLength(content, 3000);
    }

    return chapters;
  }

  static List<String> _splitByLength(String text, int chunkSize) {
    final chunks = <String>[];
    for (int i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      chunks.add(text.substring(i, end));
    }
    return chunks.isEmpty ? [text] : chunks;
  }

  static Future<ParsedBook> _parseEpub(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final epub = await epubx.EpubReader.readBook(bytes);
    final title = epub.Title ?? filePath.split('/').last;

    final chapters = <String>[];
    if (epub.Chapters != null) {
      for (final chapter in epub.Chapters!) {
        final htmlContent = chapter.HtmlContent ?? '';
        final textContent = _stripHtml(htmlContent).trim();
        if (textContent.isNotEmpty) {
          chapters.add(textContent);
        }
      }
    }

    if (chapters.isEmpty) {
      chapters.add('无法解析此 EPUB 文件的内容');
    }

    return ParsedBook(title: title, chapters: chapters);
  }

  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}
