# BookService Contract

## Purpose
Load, parse, and manage EPUB books in local storage. This is the primary interface between raw book files and the application's domain model.

## Inputs
- `file: ArrayBuffer` — raw EPUB file data from file picker
- `bookId: string` — UUID v4 unique identifier
- `fileName: string` — original filename (used as fallback title)

## Outputs
- `Book` — parsed book metadata + local file reference
- `BookChapter[]` — table of contents entries
- `ArrayBuffer` — extracted cover image data

## Behaviors

### Happy path
1. Parse EPUB metadata (title, author, language, publisher, description)
2. Extract cover image if present
3. Save file to device storage via `uni.saveFile`
4. Return `Book` object with local file path and metadata
5. Extract table of contents as `BookChapter[]`

### Edge cases
- EPUB with no cover image → `coverPath` is `undefined`
- EPUB with no metadata → use `fileName` (without extension) as title, "Unknown" as author
- EPUB with no table of contents → return single chapter with full content
- Duplicate book (same file content hash) → return existing `Book`, don't create duplicate
- Very large EPUB (>50MB) → still process, but log warning

### Error cases
- Invalid EPUB format (cannot unzip/parse) → throw `BookParseError`
- Storage full (cannot save file) → throw `StorageError` with remaining space
- File read failure → throw `FileNotFoundError`

## Invariants
- `book.id` is always a valid UUID v4 string
- `book.filePath` always points to a valid saved file on device
- A book in the library always has a corresponding file on disk
- `book.addedAt` is always a valid Unix timestamp in milliseconds
- `book.fileSize` is always > 0

## Dependencies
- `epubjs` — EPUB parsing
- `uni.saveFile` / `uni.getFileSystemManager` — file storage
- `crypto.randomUUID()` — ID generation

## Public API

```typescript
class BookService {
  /** Parse and store a new book from raw file data */
  parseBook(file: ArrayBuffer, fileName: string): Promise<Book>

  /** Get table of contents for a stored book */
  getChapters(book: Book): Promise<BookChapter[]>

  /** Extract cover image for a stored book */
  getCover(book: Book): Promise<ArrayBuffer | null>

  /** Delete a book and its stored file */
  deleteBook(bookId: string): Promise<void>

  /** Check if a book file exists on disk */
  fileExists(book: Book): Promise<boolean>
}
```
