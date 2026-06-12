/**
 * Reader store — manages reading experience state.
 * Contract: see reader.contract.md
 */

import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { Book, ReadingProgress, RenderedPage, TurnDirection } from '@/types'
import { storage } from '@/services/storage-service'
import { bookService } from '@/services/book-service'
import { paginationService } from '@/services/pagination-service'
import { useSettingsStore } from './settings'

const PROGRESS_STORAGE_KEY = 'progress'

export const useReaderStore = defineStore('reader', () => {
  // State
  const currentBook = ref<Book | null>(null)
  const progress = ref<ReadingProgress>({
    bookId: '',
    chapterIndex: 0,
    pageIndex: 0,
    percentage: 0,
    location: 0,
    updatedAt: 0,
  })
  const isToolbarVisible = ref(false)
  const isLoading = ref(false)
  const currentPage = ref<RenderedPage | null>(null)
  const totalPages = ref(0)
  const pages = ref<RenderedPage[]>([])

  // Getters
  const isReading = computed(() => currentBook.value !== null)
  const progressPercentage = computed(() => {
    if (totalPages.value === 0) return 0
    return Math.round((progress.value.pageIndex / totalPages.value) * 100)
  })
  const canGoNext = computed(() => progress.value.pageIndex < totalPages.value - 1)
  const canGoPrev = computed(() => progress.value.pageIndex > 0)

  // Actions
  async function openBook(book: Book): Promise<void> {
    isLoading.value = true
    try {
      currentBook.value = book

      // Load saved progress
      const savedProgress = storage.get<ReadingProgress>(
        `${PROGRESS_STORAGE_KEY}:${book.id}`,
      )
      if (savedProgress) {
        progress.value = savedProgress
      } else {
        progress.value = {
          bookId: book.id,
          chapterIndex: 0,
          pageIndex: 0,
          percentage: 0,
          location: 0,
          updatedAt: Date.now(),
        }
      }

      // Load chapters and paginate
      const chapters = await bookService.getChapters(book)
      if (chapters.length > 0) {
        // For now, load first chapter content
        // TODO: load content for the saved chapter
        const settingsStore = useSettingsStore()
        const settings = settingsStore.settings

        // Pagination will be done when content is loaded
        // For now, set placeholder
        totalPages.value = 1
        currentPage.value = {
          content: 'Loading...',
          pageIndex: 0,
          chapterIndex: 0,
        }
      }

      // Update last read timestamp
      book.lastReadAt = Date.now()
    } finally {
      isLoading.value = false
    }
  }

  function closeBook(): void {
    saveProgress()
    currentBook.value = null
    progress.value = {
      bookId: '',
      chapterIndex: 0,
      pageIndex: 0,
      percentage: 0,
      location: 0,
      updatedAt: 0,
    }
    pages.value = []
    currentPage.value = null
    totalPages.value = 0
    isToolbarVisible.value = false
  }

  function turnPage(direction: TurnDirection): void {
    if (direction === 'next' && canGoNext.value) {
      progress.value.pageIndex++
    } else if (direction === 'prev' && canGoPrev.value) {
      progress.value.pageIndex--
    } else {
      return
    }

    // Update current page
    if (pages.value[progress.value.pageIndex]) {
      currentPage.value = pages.value[progress.value.pageIndex]
    }

    // Auto-save progress
    saveProgress()
  }

  function goToPage(pageIndex: number): void {
    if (pageIndex < 0 || pageIndex >= totalPages.value) return

    progress.value.pageIndex = pageIndex
    if (pages.value[pageIndex]) {
      currentPage.value = pages.value[pageIndex]
    }
    saveProgress()
  }

  function goToChapter(chapterIndex: number): void {
    // TODO: implement chapter navigation
    progress.value.chapterIndex = chapterIndex
    progress.value.pageIndex = 0
    saveProgress()
  }

  function toggleToolbar(): void {
    isToolbarVisible.value = !isToolbarVisible.value
  }

  function saveProgress(): void {
    if (!currentBook.value) return

    progress.value.updatedAt = Date.now()
    progress.value.percentage = progressPercentage.value

    storage.set(
      `${PROGRESS_STORAGE_KEY}:${currentBook.value.id}`,
      progress.value,
    )
  }

  return {
    // State
    currentBook,
    progress,
    isToolbarVisible,
    isLoading,
    currentPage,
    totalPages,

    // Getters
    isReading,
    progressPercentage,
    canGoNext,
    canGoPrev,

    // Actions
    openBook,
    closeBook,
    turnPage,
    goToPage,
    goToChapter,
    toggleToolbar,
    saveProgress,
  }
})
