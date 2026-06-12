/**
 * Domain error types for AReader.
 * Typed errors for better error handling and debugging.
 */

/** Base error class for AReader domain errors */
export abstract class AReaderError extends Error {
  abstract readonly code: string

  constructor(message: string) {
    super(message)
    this.name = this.constructor.name
  }
}

/** Thrown when a book file cannot be parsed */
export class BookParseError extends AReaderError {
  readonly code = 'BOOK_PARSE_ERROR'

  constructor(
    message: string,
    public readonly filePath: string,
  ) {
    super(`Failed to parse book at ${filePath}: ${message}`)
  }
}

/** Thrown when storage operations fail */
export class StorageError extends AReaderError {
  readonly code = 'STORAGE_ERROR'

  constructor(
    message: string,
    public readonly remainingSpace?: number,
  ) {
    super(message)
  }
}

/** Thrown when a book file cannot be found */
export class FileNotFoundError extends AReaderError {
  readonly code = 'FILE_NOT_FOUND'

  constructor(public readonly filePath: string) {
    super(`File not found: ${filePath}`)
  }
}
