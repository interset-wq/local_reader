# useReaderStore Contract

## Purpose
Manage the reading experience state — current book, reading progress, page navigation, and toolbar visibility.

## State

```typescript
interface ReaderState {
  currentBook: Book | null
  progress: ReadingProgress
  isToolbarVisible: boolean
  isLoading: boolean
  currentPage: RenderedPage | null
  totalPages: number
}
```

## Behaviors

### Actions
- `openBook(book: Book)` — load book into reader, restore saved progress
- `closeBook()` — save progress, clear reader state
- `turnPage(direction: TurnDirection)` — navigate to next/prev page
- `goToPage(pageIndex: number)` — jump to specific page
- `goToChapter(chapterIndex: number)` — jump to chapter start
- `toggleToolbar()` — show/hide toolbar overlay
- `saveProgress()` — persist current progress to storage

### Getters
- `isReading` — true if a book is open
- `progressPercentage` — current position as percentage (0-100)
- `canGoNext` — true if not on last page
- `canGoPrev` — true if not on first page

### Edge cases
- Turn page past end → `canGoNext` is false, no-op
- Turn page before start → `canGoPrev` is false, no-op
- Open book with no saved progress → start at page 0, chapter 0
- Open book with saved progress → restore exact position
- Close book without saving → auto-save on close

### Invariants
- `currentBook` is null when not reading
- `progress.bookId` always matches `currentBook.id` when reading
- `pageIndex` is always >= 0 and < `totalPages`
- Progress is auto-saved on every page turn

## Dependencies
- `PaginationService` — content pagination
- `StorageService` — progress persistence
- `BookService` — load book content
