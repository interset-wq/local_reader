# AGENTS.md — local_reader

## Project

Flutter Android local novel reader (also builds for Linux desktop for preview).
Reads .txt and .epub files from device storage, renders them in a chapter-based reader
with page-flip and scroll modes, bookmarks, search, and customizable reading settings.

## Commands

| Task | Command |
|------|---------|
| Install deps | `flutter pub get` |
| Analyze | `flutter analyze` |
| Run tests | `flutter test` |
| Run on Linux (preview) | `flutter run -d linux` |
| Run on Android | `flutter run -d <device-id>` |
| Build debug APK | `flutter build apk --debug` |
| Build release APK | `flutter build apk --release` |
| Build Linux | `flutter build linux --debug` |
| List devices | `flutter devices` |

Always run `flutter analyze` after changes. It must report zero issues.

## Architecture

```
lib/
├── main.dart                  # Entry point, AppSettings (ChangeNotifier), theme routing
├── models/book.dart           # Book + Bookmark data models with JSON serialization
├── services/
│   ├── file_service.dart      # FilePicker + copy to app documents dir
│   ├── parser_service.dart    # TXT chapter splitting (regex) + EPUB parsing (epubx)
│   └── storage_service.dart   # SharedPreferences persistence
├── screens/
│   ├── home_screen.dart       # Bookshelf list, sorting, search, import, delete with file cleanup
│   ├── reader_screen.dart     # Page/scroll reader, toolbar, brightness, bookmarks, chapter nav
│   ├── settings_screen.dart   # Theme, reading mode, font, line height, brightness
│   ├── search_screen.dart     # Full-text search across all chapters
│   └── bookmark_screen.dart   # Bookmark list with swipe-to-delete
└── theme/app_theme.dart       # Three ThemeData definitions (light/dark/sepia)
```

## Key patterns

- **State management**: `provider` + `ChangeNotifier` (`AppSettings` in `main.dart`). Single provider wraps the whole app via `ChangeNotifierProvider`.
- **Persistence**: `shared_preferences` for settings and book list (JSON string). Book files copied to `getApplicationDocumentsDirectory()/books/`.
- **TXT parsing**: Regex splits on `第X章/节/回/卷` or `Chapter N`. Falls back to 3000-char chunks.
- **EPUB parsing**: `epubx` package, strips HTML tags for plain-text rendering.
- **Bookmarks**: Stored per-book in the `Book.bookmarks` list. Each bookmark records chapter index, char offset, and a text preview.
- **Delete flow**: Removes book from list AND deletes the file from disk.

## Features

- Bookshelf with sorting (recent/title/progress), title search, progress bar per book
- Two reading modes: page-flip (horizontal swipe) and vertical scroll
- Chapter navigation via slider and chapter list bottom sheet
- Full-text search across all chapters with context previews
- Bookmark system: add bookmarks from reader toolbar, view/jump/delete bookmarks
- Brightness overlay control (in-app, does not affect system brightness)
- Font settings: size (14–28), line height (1.2–2.5), font family (serif/sans-serif/monospace)
- Three themes: light, dark, sepia

## Platform notes

- Primary target: **Android**. Linux desktop is for local dev preview only.
- `file_picker` works on both Android and Linux.
- `path_provider` resolves correctly on both platforms.
- Linux build output: `build/linux/x64/debug/bundle/local_reader`
- Sample books in `book/` directory (gitignored).

## Conventions

- Chinese UI strings (书架, 设置, etc.) — keep all user-facing text in Chinese.
- No network dependencies — fully offline app.
- `publish_to: 'none'` in pubspec.yaml — private package.
- `flutter_lints` for lint rules (via `analysis_options.yaml`).
