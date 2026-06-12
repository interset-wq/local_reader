/**
 * Library store — manages the user's book collection.
 * Contract: see library.contract.md
 */

import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { Book, BookFilter, BookSortBy } from '@/types'
import { storage } from '@/services/storage-service'
import { bookService } from '@/services/book-service'

const STORAGE_KEY = 'library'

export const useLibraryStore = defineStore('library', () => {
  // State
  const books = ref<Book[]>([])
  const isLoading = ref(false)
  const filter = ref<BookFilter>({
    sortBy: 'addedAt',
    sortOrder: 'desc',
  })

  // Getters
  const filteredBooks = computed(() => {
    let result = [...books.value]

    // Apply text filter
    if (filter.value.query) {
      const q = filter.value.query.toLowerCase()
      result = result.filter(
        (b) =>
          b.title.toLowerCase().includes(q) ||
          b.author.toLowerCase().includes(q),
      )
    }

    // Apply format filter
    if (filter.value.format) {
      result = result.filter((b) => b.format === filter.value.format)
    }

    // Apply sort
    result.sort((a, b) => {
      const sortBy = filter.value.sortBy
      const order = filter.value.sortOrder === 'asc' ? 1 : -1

      if (sortBy === 'title' || sortBy === 'author') {
        return a[sortBy].localeCompare(b[sortBy]) * order
      }

      return ((a[sortBy] ?? 0) - (b[sortBy] ?? 0)) * order
    })

    return result
  })

  const bookCount = computed(() => books.value.length)

  // Actions
  function loadLibrary(): void {
    isLoading.value = true
    try {
      const saved = storage.get<Book[]>(STORAGE_KEY)
      if (saved) {
        books.value = saved
      }
    } finally {
      isLoading.value = false
    }
  }

  function persistLibrary(): void {
    storage.set(STORAGE_KEY, books.value)
  }

  function addBook(book: Book): void {
    const existingIndex = books.value.findIndex((b) => b.id === book.id)
    if (existingIndex >= 0) {
      // Update existing book
      books.value[existingIndex] = book
    } else {
      // Add new book
      books.value.push(book)
    }
    persistLibrary()
  }

  function removeBook(bookId: string): void {
    const index = books.value.findIndex((b) => b.id === bookId)
    if (index < 0) return

    const book = books.value[index]
    books.value.splice(index, 1)
    persistLibrary()

    // Clean up files (best effort)
    bookService.deleteBook(bookId).catch(() => {})
  }

  function updateBook(bookId: string, updates: Partial<Book>): void {
    const index = books.value.findIndex((b) => b.id === bookId)
    if (index < 0) return

    books.value[index] = { ...books.value[index], ...updates }
    persistLibrary()
  }

  function setFilter(newFilter: Partial<BookFilter>): void {
    filter.value = { ...filter.value, ...newFilter }
  }

  function getBookById(id: string): Book | null {
    return books.value.find((b) => b.id === id) ?? null
  }

  return {
    // State
    books,
    isLoading,
    filter,

    // Getters
    filteredBooks,
    bookCount,

    // Actions
    loadLibrary,
    addBook,
    removeBook,
    updateBook,
    setFilter,
    getBookById,
  }
})
