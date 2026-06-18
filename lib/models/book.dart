import 'dart:convert';

class Bookmark {
  final String id;
  final int chapterIndex;
  final int charOffset;
  final String preview;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.chapterIndex,
    required this.charOffset,
    required this.preview,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'chapterIndex': chapterIndex,
        'charOffset': charOffset,
        'preview': preview,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        id: json['id'],
        chapterIndex: json['chapterIndex'],
        charOffset: json['charOffset'],
        preview: json['preview'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class Book {
  final String id;
  final String title;
  final String filePath;
  final String fileType;
  int currentChapter;
  int currentCharOffset;
  int totalChapters;
  List<Bookmark> bookmarks;
  DateTime lastRead;
  DateTime addedAt;
  int colorIndex;

  Book({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileType,
    this.currentChapter = 0,
    this.currentCharOffset = 0,
    this.totalChapters = 0,
    List<Bookmark>? bookmarks,
    DateTime? lastRead,
    DateTime? addedAt,
    this.colorIndex = 0,
  })  : bookmarks = bookmarks ?? [],
        lastRead = lastRead ?? DateTime.now(),
        addedAt = addedAt ?? DateTime.now();

  double get progress {
    if (totalChapters <= 0) return 0;
    return (currentChapter + 1) / totalChapters;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'filePath': filePath,
        'fileType': fileType,
        'currentChapter': currentChapter,
        'currentCharOffset': currentCharOffset,
        'totalChapters': totalChapters,
        'bookmarks': bookmarks.map((b) => b.toJson()).toList(),
        'lastRead': lastRead.toIso8601String(),
        'addedAt': addedAt.toIso8601String(),
        'colorIndex': colorIndex,
      };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'],
        title: json['title'],
        filePath: json['filePath'],
        fileType: json['fileType'],
        currentChapter: json['currentChapter'] ?? 0,
        currentCharOffset: json['currentCharOffset'] ?? 0,
        totalChapters: json['totalChapters'] ?? 0,
        bookmarks: (json['bookmarks'] as List<dynamic>?)
                ?.map((b) => Bookmark.fromJson(b))
                .toList() ??
            [],
        lastRead: DateTime.parse(json['lastRead']),
        addedAt: json['addedAt'] != null
            ? DateTime.parse(json['addedAt'])
            : DateTime.now(),
        colorIndex: json['colorIndex'] ?? 0,
      );

  static List<Book> listFromJson(String jsonString) {
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((e) => Book.fromJson(e)).toList();
  }

  static String listToJson(List<Book> books) {
    return jsonEncode(books.map((e) => e.toJson()).toList());
  }
}
