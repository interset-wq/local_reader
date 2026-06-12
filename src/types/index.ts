/**
 * Central type exports for AReader.
 * Import all types from here for convenience.
 */

export type {
  BookFormat,
  Book,
  BookMetadata,
  BookChapter,
  BookSortBy,
  BookFilter,
} from './book'

export type {
  ReadingProgress,
  PagePosition,
  RenderedPage,
  ReaderState,
  TapZone,
  TurnDirection,
} from './reader'

export type {
  Theme,
  FontConfig,
  UserSettings,
} from './settings'

export { DEFAULT_SETTINGS } from './settings'

export {
  AReaderError,
  BookParseError,
  StorageError,
  FileNotFoundError,
} from './errors'
