/**
 * Book service — EPUB parsing and file management.
 * Contract: see book-service.contract.md
 */

import ePub from 'epubjs'
import type { Book, BookMetadata, BookChapter } from '@/types'
import { BookParseError, FileNotFoundError, StorageError } from '@/types/errors'
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
    let book: ReturnType<typeof ePub>
    try {
      book = ePub(file)
      await book.ready
    } catch (e) {
      throw new BookParseError(
        e instanceof Error ? e.message : 'Unknown parsing error',
        fileName,
      )
    }

    // Extract metadata
    const metadata = book.packaging?.metadata
    const title = metadata?.title ?? fileName.replace(/\.[^/.]+$/, '')
    const author = metadata?.creator ?? 'Unknown'

    // Save file to device storage
    let filePath: string
    try {
      filePath = await this.saveFileToStorage(file, fileName)
    } catch (e) {
      book.destroy()
      throw new StorageError(
        `Failed to save book file: ${e instanceof Error ? e.message : String(e)}`,
      )
    }

    // Extract cover (best effort)
    let coverPath: string | undefined
    try {
      const coverUrl = await book.loaded.cover
      if (coverUrl) {
        const coverBlob = await book.archive.getBlob(coverUrl)
        if (coverBlob) {
          coverPath = await this.saveCoverToStorage(coverBlob, title)
        }
      }
    } catch {
      // No cover — that's fine
    }

    const bookData: Book = {
      id: generateId(),
      title,
      author,
      format: 'epub',
      filePath,
      coverPath,
      fileSize: file.byteLength,
      addedAt: Date.now(),
    }

    book.destroy()
    return bookData
  }

  /**
   * Get table of contents for a stored book.
   */
  async getChapters(book: Book): Promise<BookChapter[]> {
    const fileData = await this.readFileFromStorage(book.filePath)
    const epub = ePub(fileData)

    try {
      await epub.ready
      const navigation = await epub.loaded.navigation
      return navigation.toc.map((chapter: any, index: number) => ({
        id: chapter.id ?? String(index),
        title: chapter.label ?? `Chapter ${index + 1}`,
        href: chapter.href ?? '',
        level: chapter.level ?? 0,
      }))
    } finally {
      epub.destroy()
    }
  }

  /**
   * Delete a book and its stored file.
   */
  async deleteBook(bookId: string): Promise<void> {
    const books = storage.get<Book[]>(BOOKS_STORAGE_KEY) ?? []
    const book = books.find((b) => b.id === bookId)
    if (!book) return

    // Remove file
    try {
      await this.removeFile(book.filePath)
    } catch {
      // File may already be deleted
    }

    // Remove cover
    if (book.coverPath) {
      try {
        await this.removeFile(book.coverPath)
      } catch {
        // Ignore
      }
    }
  }

  /**
   * Check if a book file exists on disk.
   */
  async fileExists(book: Book): Promise<boolean> {
    try {
      const fs = uni.getFileSystemManager()
      return new Promise((resolve) => {
        fs.access({
          path: book.filePath,
          success: () => resolve(true),
          fail: () => resolve(false),
        })
      })
    } catch {
      return false
    }
  }

  // --- Private helpers ---

  private saveFileToStorage(data: ArrayBuffer, fileName: string): Promise<string> {
    return new Promise((resolve, reject) => {
      // Write to temp file first, then save permanently
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

  private saveCoverToStorage(blob: Blob, bookTitle: string): Promise<string> {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.onload = () => {
        const fs = uni.getFileSystemManager()
        const path = `${(uni as any).env.USER_DATA_PATH}/cover_${bookTitle.replace(/\s+/g, '_')}.jpg`
        fs.writeFile({
          filePath: path,
          data: reader.result as ArrayBuffer,
          success: () => resolve(path),
          fail: (err) => reject(new Error(err.errMsg)),
        })
      }
      reader.onerror = () => reject(new Error('Failed to read cover blob'))
      reader.readAsArrayBuffer(blob)
    })
  }

  private readFileFromStorage(filePath: string): Promise<ArrayBuffer> {
    return new Promise((resolve, reject) => {
      const fs = uni.getFileSystemManager()
      fs.readFile({
        filePath,
        success: (res) => resolve(res.data as ArrayBuffer),
        fail: (err) => reject(new FileNotFoundError(filePath)),
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
