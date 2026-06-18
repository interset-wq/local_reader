import 'dart:convert';

class Book {
  final String id;
  final String title;
  final String filePath;
  final String fileType; // 'txt' or 'epub'
  int currentChapter;
  int currentPage;
  DateTime lastRead;

  Book({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileType,
    this.currentChapter = 0,
    this.currentPage = 0,
    DateTime? lastRead,
  }) : lastRead = lastRead ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'filePath': filePath,
        'fileType': fileType,
        'currentChapter': currentChapter,
        'currentPage': currentPage,
        'lastRead': lastRead.toIso8601String(),
      };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'],
        title: json['title'],
        filePath: json['filePath'],
        fileType: json['fileType'],
        currentChapter: json['currentChapter'] ?? 0,
        currentPage: json['currentPage'] ?? 0,
        lastRead: DateTime.parse(json['lastRead']),
      );

  static List<Book> listFromJson(String jsonString) {
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((e) => Book.fromJson(e)).toList();
  }

  static String listToJson(List<Book> books) {
    return jsonEncode(books.map((e) => e.toJson()).toList());
  }
}
