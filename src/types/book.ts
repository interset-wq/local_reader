/**
 * Book domain types for AReader.
 * These types are the single source of truth for book-related data structures.
 */

/** Supported book formats */
export type BookFormat = 'epub' | 'pdf'

/** A book stored in the library */
export interface Book {
  readonly id: string
  readonly title: string
  readonly author: string
  readonly format: BookFormat
  readonly filePath: string
  readonly coverPath?: string
  readonly fileSize: number
  readonly addedAt: number
  lastReadAt?: number
}

/** Metadata extracted from a book file */
export interface BookMetadata {
  title: string
  author: string
  description?: string
  language?: string
  publisher?: string
  publishedDate?: string
  cover?: ArrayBuffer
}

/** A chapter entry in the table of contents */
export interface BookChapter {
  id: string
  title: string
  href: string
  level: number
}

/** Book library sort options */
export type BookSortBy = 'title' | 'author' | 'addedAt' | 'lastReadAt'

/** Book library filter options */
export interface BookFilter {
  query?: string
  format?: BookFormat
  sortBy: BookSortBy
  sortOrder: 'asc' | 'desc'
}
