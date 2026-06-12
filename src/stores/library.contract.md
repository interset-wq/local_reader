# useLibraryStore Contract

## Purpose
Manage the user's book library — the collection of imported books with their metadata and state.

## State

```typescript
interface LibraryState {
  books: Book[]
  isLoading: boolean
  filter: BookFilter
}
```

## Behaviors

### Actions
- `addBook(book: Book)` — add book to library, persist to storage
- `removeBook(bookId: string)` — remove book from library and storage
- `updateBook(bookId: string, updates: Partial<Book>)` — update book metadata
- `setFilter(filter: Partial<BookFilter>)` — update filter/sort options
- `loadLibrary()` — load library from storage on app start

### Getters
- `filteredBooks` — books matching current filter, sorted by current sort
- `bookCount` — total number of books
- `getBookById(id: string)` — find book by ID or return null

### Edge cases
- Adding duplicate book (same ID) → update existing, don't create duplicate
- Removing non-existent book → no-op (no error)
- Empty library → `filteredBooks` returns empty array
- Filter with no matches → returns empty array

### Invariants
- `books` array never contains duplicates (by ID)
- All books in state have valid file references
- State is persisted to storage after every mutation

## Dependencies
- `StorageService` — persistence
- `BookService` — file operations
