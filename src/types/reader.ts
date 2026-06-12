/**
 * Reader state types for AReader.
 * Defines the reading experience state and position tracking.
 */

import type { Book } from './book'

/** Current reading progress for a book */
export interface ReadingProgress {
  bookId: string
  chapterIndex: number
  pageIndex: number
  percentage: number
  location: number
  updatedAt: number
}

/** A position in the book (chapter + page) */
export interface PagePosition {
  chapterIndex: number
  pageIndex: number
  offset: number
}

/** A single rendered page of content */
export interface RenderedPage {
  content: string
  pageIndex: number
  chapterIndex: number
}

/** Reader UI state */
export interface ReaderState {
  currentBook: Book | null
  progress: ReadingProgress
  isToolbarVisible: boolean
  isLoading: boolean
  currentPage: RenderedPage | null
  totalPages: number
}

/** Tap zone on the reader screen */
export type TapZone = 'prev' | 'next' | 'center'

/** Page turn direction */
export type TurnDirection = 'prev' | 'next'
