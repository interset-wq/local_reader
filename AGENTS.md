# AGENTS.md — local_reader

## Project

Flutter Android local novel reader (also builds for Linux desktop for preview).
Reads .txt and .epub files from device storage, renders them in a swipeable chapter-based reader.

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
├── main.dart              # Entry point, AppSettings (ChangeNotifier), theme routing
├── models/book.dart       # Book data model with JSON serialization
├── services/
│   ├── file_service.dart  # FilePicker + copy to app documents dir
│   ├── parser_service.dart# TXT chapter splitting (regex) + EPUB parsing (epubx)
│   └── storage_service.dart # SharedPreferences persistence
├── screens/
│   ├── home_screen.dart   # Bookshelf grid, import flow, delete on long-press
│   ├── reader_screen.dart # PageView-based reader, toolbar, chapter list bottom sheet
│   └── settings_screen.dart # Theme (day/dark/sepia), font size, line height, font family
└── theme/app_theme.dart   # Three ThemeData definitions
```

## Key patterns

- **State management**: `provider` + `ChangeNotifier` (`AppSettings` in `main.dart`). Single provider wraps the whole app via `ChangeNotifierProvider`.
- **Persistence**: `shared_preferences` for settings and book list (JSON string). Book files copied to `getApplicationDocumentsDirectory()/books/`.
- **TXT parsing**: Regex splits on `第X章/节/回/卷` or `Chapter N`. Falls back to 3000-char chunks.
- **EPUB parsing**: `epubx` package, strips HTML tags for plain-text rendering.

## Platform notes

- Primary target: **Android**. Linux desktop is for local dev preview only.
- `file_picker` works on both Android and Linux.
- `path_provider` resolves correctly on both platforms.
- Linux build output: `build/linux/x64/debug/bundle/local_reader`

## Conventions

- Chinese UI strings (书架, 设置, etc.) — keep all user-facing text in Chinese.
- No network dependencies — fully offline app.
- `publish_to: 'none'` in pubspec.yaml — private package.
- `flutter_lints` for lint rules (via `analysis_options.yaml`).
