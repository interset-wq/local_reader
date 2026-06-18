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
│   ├── home_screen.dart       # Bookshelf grid, continue-reading hero, search, import, delete
│   ├── reader_screen.dart     # Page/scroll reader, Kindle-style toolbar, Aa menu, bookmarks
│   ├── settings_screen.dart   # Theme, reading mode, font, line height, brightness
│   ├── search_screen.dart     # Full-text search across all chapters
│   └── bookmark_screen.dart   # Bookmark list with swipe-to-delete
└── theme/app_theme.dart       # Theme system: white/sepia/dark/black with helper methods
```

## Key patterns

- **State management**: `provider` + `ChangeNotifier` (`AppSettings` in `main.dart`). Single provider wraps the whole app via `ChangeNotifierProvider`.
- **Persistence**: `shared_preferences` for settings and book list (JSON string). Book files copied to `getApplicationDocumentsDirectory()/books/`.
- **TXT parsing**: Regex splits on `第X章/节/回/卷` or `Chapter N`. Falls back to 3000-char chunks.
- **EPUB parsing**: `epubx` package, strips HTML tags for plain-text rendering.
- **Bookmarks**: Stored per-book in the `Book.bookmarks` list. Each bookmark records chapter index, char offset, and a text preview.
- **Delete flow**: Removes book from list AND deletes the file from disk.
- **Theme system**: 4 modes (white/sepia/dark/black). `AppTheme` provides colors via static helpers. System UI bar colors updated via `AppTheme.setSystemUi()`.

## Features

- Bookshelf with cover grid, continue-reading hero card, title search
- Two reading modes: page-flip (horizontal swipe) and vertical scroll
- Kindle-style tap zones: left/right edges navigate chapters, center toggles toolbar
- Chapter navigation via slider and chapter list bottom sheet
- Full-text search across all chapters with context previews
- Bookmark system: add bookmarks from reader toolbar, view/jump/delete bookmarks
- Aa menu: theme picker (4 themes), brightness, font size, line height, font family
- Thin progress line at reader bottom (always visible, shows chapter/percent)
- Brightness overlay control (in-app, does not affect system brightness)
- Font settings: size (14–28), line height (1.2–2.5), font family (serif/sans-serif/monospace)

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
