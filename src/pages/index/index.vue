<script setup lang="ts">
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useLibraryStore } from '@/stores/library'
import { useSettingsStore } from '@/stores/settings'
import { useTheme } from '@/composables/useTheme'
import { bookService } from '@/services/book-service'
import type { Book } from '@/types'

const libraryStore = useLibraryStore()
const settingsStore = useSettingsStore()

// Apply theme
useTheme()

// Load data on show
onShow(() => {
  libraryStore.loadLibrary()
  settingsStore.loadSettings()
})

// Import book
async function importBook(): Promise<void> {
  try {
    // #ifdef H5
    const input = document.createElement('input')
    input.type = 'file'
    input.accept = '.epub'

    input.onchange = async (e: Event) => {
      const file = (e.target as HTMLInputElement).files?.[0]
      if (!file) return

      const buffer = await file.arrayBuffer()
      const book = await bookService.parseBook(buffer, file.name)
      libraryStore.addBook(book)

      uni.showToast({ title: 'Book imported', icon: 'success' })
    }
    input.click()
    // #endif

    // #ifdef APP-PLUS
    uni.chooseFile({
      type: 'all',
      extension: ['.epub'],
      success: async (res) => {
        const filePath = res.tempFilePaths[0]
        if (!filePath) return

        const fs = uni.getFileSystemManager()
        fs.readFile({
          filePath,
          success: async (readRes) => {
            const buffer = readRes.data as ArrayBuffer
            const fileName = filePath.split('/').pop() ?? 'unknown.epub'
            const book = await bookService.parseBook(buffer, fileName)
            libraryStore.addBook(book)
            uni.showToast({ title: 'Book imported', icon: 'success' })
          },
        })
      },
    })
    // #endif
  } catch (e) {
    uni.showToast({
      title: e instanceof Error ? e.message : 'Import failed',
      icon: 'error',
    })
  }
}

// Open book in reader
function openBook(book: Book): void {
  uni.navigateTo({
    url: `/pages/reader/reader?bookId=${book.id}`,
  })
}

// Delete book
function deleteBook(book: Book): void {
  uni.showModal({
    title: 'Delete Book',
    content: `Delete "${book.title}"?`,
    success: (res) => {
      if (res.confirm) {
        libraryStore.removeBook(book.id)
      }
    },
  })
}
</script>

<template>
  <view class="library">
    <!-- Header -->
    <view class="library-header">
      <text class="library-title">My Library</text>
      <view class="library-actions">
        <view class="btn-import" @tap="importBook">
          <text>+ Import</text>
        </view>
      </view>
    </view>

    <!-- Book Grid -->
    <view v-if="libraryStore.filteredBooks.length > 0" class="book-grid">
      <view
        v-for="book in libraryStore.filteredBooks"
        :key="book.id"
        class="book-card"
        @tap="openBook(book)"
        @longpress="deleteBook(book)"
      >
        <view class="book-cover">
          <image
            v-if="book.coverPath"
            :src="book.coverPath"
            mode="aspectFit"
            class="cover-image"
          />
          <view v-else class="cover-placeholder">
            <text class="cover-title">{{ book.title }}</text>
          </view>
        </view>
        <text class="book-title">{{ book.title }}</text>
        <text class="book-author">{{ book.author }}</text>
      </view>
    </view>

    <!-- Empty State -->
    <view v-else class="empty-state">
      <text class="empty-icon">📚</text>
      <text class="empty-title">No books yet</text>
      <text class="empty-description">Import an EPUB file to get started</text>
      <view class="btn-import-large" @tap="importBook">
        <text>Import Book</text>
      </view>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.library {
  min-height: 100vh;
  background-color: var(--bg-color, #ffffff);
  padding: 24rpx;
}

.library-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32rpx;
}

.library-title {
  font-size: 48rpx;
  font-weight: bold;
  color: var(--text-color, #1a1a1a);
}

.btn-import {
  padding: 16rpx 32rpx;
  background-color: #4a90d9;
  border-radius: 8rpx;
  color: #ffffff;
  font-size: 28rpx;
}

.book-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 24rpx;
}

.book-card {
  width: calc(33.333% - 16rpx);
  margin-bottom: 24rpx;
}

.book-cover {
  width: 100%;
  aspect-ratio: 2 / 3;
  border-radius: 8rpx;
  overflow: hidden;
  background-color: #f0f0f0;
  margin-bottom: 12rpx;
}

.cover-image {
  width: 100%;
  height: 100%;
}

.cover-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16rpx;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.cover-title {
  color: #ffffff;
  font-size: 24rpx;
  text-align: center;
  word-break: break-word;
}

.book-title {
  font-size: 24rpx;
  font-weight: 600;
  color: var(--text-color, #1a1a1a);
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.book-author {
  font-size: 20rpx;
  color: var(--text-secondary, #666666);
  margin-top: 4rpx;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding-top: 200rpx;
}

.empty-icon {
  font-size: 96rpx;
  margin-bottom: 24rpx;
}

.empty-title {
  font-size: 36rpx;
  font-weight: 600;
  color: var(--text-color, #1a1a1a);
  margin-bottom: 12rpx;
}

.empty-description {
  font-size: 28rpx;
  color: var(--text-secondary, #666666);
  margin-bottom: 48rpx;
}

.btn-import-large {
  padding: 24rpx 64rpx;
  background-color: #4a90d9;
  border-radius: 12rpx;
  color: #ffffff;
  font-size: 32rpx;
}
</style>
