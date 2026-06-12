---
name: spec-driven-dev
description: Specification-Driven Development workflow for AReader. Use when creating new features, modules, services, composables, or stores. Enforces types-first, contracts-before-code, tests-from-specs methodology.
---

# Specification-Driven Development (SDD)

## When to Use

- Creating any new module (service, composable, store, component)
- Adding a new feature to an existing module
- Refactoring existing code (update spec first, then code)
- Fixing bugs (spec the expected behavior first)

## Workflow

```
SPECIFY → VALIDATE → IMPLEMENT → VERIFY → ITERATE
```

### Step 1: SPECIFY — Types & Contracts

Before writing ANY implementation code:

1. **Define types** in `src/types/`:
```typescript
// src/types/book.ts
export interface Book {
  readonly id: string
  readonly title: string
  readonly author: string
  readonly format: 'epub' | 'pdf'
  readonly filePath: string
  readonly coverPath?: string
  readonly addedAt: number
}

export interface BookMetadata {
  title: string
  author: string
  description?: string
  language?: string
  publisher?: string
  publishedDate?: string
}
```

2. **Write contract** as `.contract.md` next to the implementation file:
```markdown
# BookService Contract

## Purpose
Load, parse, and manage EPUB books in local storage.

## Inputs
- `file: ArrayBuffer` — raw EPUB file data
- `bookId: string` — unique identifier

## Outputs
- `Book` — parsed book metadata + file reference
- `BookChapter[]` — table of contents

## Behaviors
### Happy path
- Parse EPUB metadata (title, author, cover)
- Save file to device storage via uni.saveFile
- Return Book object with local file path

### Edge cases
- EPUB with no cover image → use placeholder
- EPUB with no metadata → use filename as title
- Duplicate book (same file hash) → return existing, don't duplicate

### Error cases
- Invalid EPUB format → throw BookParseError
- Storage full → throw StorageError with remaining space info
- File read failure → throw FileReadError with path

## Invariants
- `book.id` is always unique (UUID v4)
- `book.filePath` always points to a valid saved file
- A book in the library always has a corresponding file on disk

## Dependencies
- `uni.saveFile` / `uni.getFileSystemManager` — file storage
- `epubjs` — EPUB parsing
- `useLibraryStore` — persists book list
```

### Step 2: VALIDATE — Review & Type Check

- Review types with `vue-tsc --noEmit`
- Ensure all interfaces are exported
- Check that contract covers all edge cases
- Verify no `any` types exist

### Step 3: IMPLEMENT — Code to Spec

- Write implementation that satisfies the types and contract
- Follow the contract's behaviors exactly — no implicit behavior
- If you discover a new edge case: STOP, update the contract first, then implement

### Step 4: VERIFY — Tests from Spec

Every contract behavior maps to test(s):

```typescript
// src/services/book-service.spec.ts
import { describe, it, expect, vi } from 'vitest'
import { BookService } from './book-service'

describe('BookService', () => {
  describe('parseBook', () => {
    // Happy path
    it('parses EPUB metadata and returns Book', async () => {
      const result = await service.parseBook(validEpubBuffer)
      expect(result.title).toBe('Test Book')
      expect(result.author).toBe('Test Author')
    })

    // Edge case: no cover
    it('uses placeholder when EPUB has no cover', async () => {
      const result = await service.parseBook(noCoverEpubBuffer)
      expect(result.coverPath).toBeUndefined()
    })

    // Edge case: no metadata
    it('uses filename when EPUB has no metadata', async () => {
      const result = await service.parseBook(noMetadataBuffer, 'my-book.epub')
      expect(result.title).toBe('my-book')
    })

    // Error case
    it('throws BookParseError for invalid EPUB', async () => {
      await expect(service.parseBook(invalidBuffer))
        .rejects.toThrow(BookParseError)
    })

    // Error case: duplicate
    it('returns existing book for duplicate file', async () => {
      const first = await service.parseBook(validEpubBuffer)
      const second = await service.parseBook(validEpubBuffer)
      expect(first.id).toBe(second.id)
    })
  })
})
```

### Step 5: ITERATE — Refine

- Run `vue-tsc --noEmit` + `pnpm test`
- If tests fail: check contract → fix code (not test)
- If contract is wrong: update contract → update tests → fix code
- If new edge case discovered: update contract → add test → implement

## File Naming

| File | Pattern | Example |
|------|---------|---------|
| Types | `src/types/{name}.ts` | `src/types/book.ts` |
| Contract | `src/{path}/{name}.contract.md` | `src/services/book-service.contract.md` |
| Tests | `src/{path}/{name}.spec.ts` | `src/services/book-service.spec.ts` |
| Implementation | `src/{path}/{name}.ts` | `src/services/book-service.ts` |

## Anti-Patterns (MUST NOT)

- ❌ Write implementation before types
- ❌ Skip the contract file for "simple" modules
- ❌ Use `any` type — use `unknown` and narrow
- ❌ Add behavior not in the contract without updating it first
- ❌ Let tests and contract diverge
- ❌ Treat contract as documentation-only — it's a binding specification

## Checklist for New Feature

- [ ] Types defined in `src/types/`
- [ ] Contract written as `.contract.md`
- [ ] `vue-tsc --noEmit` passes
- [ ] Tests written for all contract behaviors
- [ ] Tests for happy path, edge cases, error cases
- [ ] Implementation satisfies all tests
- [ ] No `any` types
- [ ] Contract updated if edge cases discovered during implementation
