/**
 * Book service — EPUB parsing and file management.
 * Contract: see book-service.contract.md
 *
 * TODO: epubjs integration (lazy-loaded) — currently stubbed for preview.
 */

import type { Book, BookChapter } from '@/types'
import { BookParseError, StorageError } from '@/types/errors'
import { storage } from './storage-service'

const BOOKS_STORAGE_KEY = 'books'

function generateId(): string {
  return crypto.randomUUID()
}

export class BookService {
  /**
   * Parse and store a new book from raw file data.
   */
  async parseBook(file: ArrayBuffer, fileName: string): Promise<Book> {
    // Stub: extract title from filename
    const title = fileName.replace(/\.[^/.]+$/, '')
    const author = 'Unknown'

    // Save file to device storage
    let filePath: string
    try {
      filePath = await this.saveFileToStorage(file, fileName)
    } catch (e) {
      throw new StorageError(
        `Failed to save book file: ${e instanceof Error ? e.message : String(e)}`,
      )
    }

    return {
      id: generateId(),
      title,
      author,
      format: 'epub',
      filePath,
      fileSize: file.byteLength,
      addedAt: Date.now(),
    }
  }

  /**
   * Get table of contents for a stored book.
   */
  async getChapters(_book: Book): Promise<BookChapter[]> {
    // Stub: return single chapter
    return [{
      id: '0',
      title: 'Full Content',
      href: '',
      level: 0,
    }]
  }

  /**
   * Delete a book and its stored file.
   */
  async deleteBook(bookId: string): Promise<void> {
    const books = storage.get<Book[]>(BOOKS_STORAGE_KEY) ?? []
    const book = books.find((b) => b.id === bookId)
    if (!book) return

    try {
      await this.removeFile(book.filePath)
    } catch {
      // File may already be deleted
    }

    if (book.coverPath) {
      try {
        await this.removeFile(book.coverPath)
      } catch {
        // Ignore
      }
    }
  }

  // --- Private helpers ---

  private saveFileToStorage(data: ArrayBuffer, fileName: string): Promise<string> {
    return new Promise((resolve, reject) => {
      const fs = uni.getFileSystemManager()
      const tempPath = `${(uni as any).env.USER_DATA_PATH}/temp_${Date.now()}_${fileName}`

      fs.writeFile({
        filePath: tempPath,
        data,
        success: () => {
          uni.saveFile({
            tempFilePath: tempPath,
            success: (res) => resolve(res.savedFilePath),
            fail: (err) => reject(new Error(err.errMsg)),
          })
        },
        fail: (err) => reject(new Error(err.errMsg)),
      })
    })
  }

  private removeFile(filePath: string): Promise<void> {
    return new Promise((resolve, reject) => {
      const fs = uni.getFileSystemManager()
      fs.unlink({
        filePath,
        success: () => resolve(),
        fail: (err) => reject(new Error(err.errMsg)),
      })
    })
  }
}

/** Singleton instance */
export const bookService = new BookService()
