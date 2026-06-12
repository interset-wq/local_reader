<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { onLoad, onUnload } from '@dcloudio/uni-app'
import { useReaderStore } from '@/stores/reader'
import { useSettingsStore } from '@/stores/settings'
import { useSwipeGesture } from '@/composables/useSwipeGesture'
import { useTheme } from '@/composables/useTheme'
import { useLibraryStore } from '@/stores/library'
import type { TapZone, TurnDirection } from '@/types'

const readerStore = useReaderStore()
const settingsStore = useSettingsStore()
const libraryStore = useLibraryStore()

// Apply theme
useTheme()

// Load book on page load
onLoad((query) => {
  const bookId = query?.bookId
  if (!bookId) {
    uni.navigateBack()
    return
  }

  const book = libraryStore.getBookById(bookId)
  if (!book) {
    uni.showToast({ title: 'Book not found', icon: 'error' })
    uni.navigateBack()
    return
  }

  readerStore.openBook(book)
})

// Save progress on unload
onUnload(() => {
  readerStore.closeBook()
})

// Handle tap zones
function handleTapZone(zone: TapZone): void {
  switch (zone) {
    case 'prev':
      readerStore.turnPage('prev')
      break
    case 'next':
      readerStore.turnPage('next')
      break
    case 'center':
      readerStore.toggleToolbar()
      break
  }
}

// Handle swipe gestures
function handleSwipe(direction: TurnDirection): void {
  readerStore.turnPage(direction)
}

// Setup swipe gesture
useSwipeGesture({
  onTapZone: handleTapZone,
  onSwipe: handleSwipe,
})

// Toolbar actions
function adjustFontSize(delta: number): void {
  settingsStore.setFontSize(settingsStore.settings.font.size + delta)
}

function toggleTheme(): void {
  const themes = ['light', 'dark', 'sepia'] as const
  const currentIndex = themes.indexOf(settingsStore.currentTheme)
  const nextIndex = (currentIndex + 1) % themes.length
  settingsStore.setTheme(themes[nextIndex])
}

function goBack(): void {
  uni.navigateBack()
}

function onSliderChange(e: { detail: { value: number } }): void {
  readerStore.goToPage(e.detail.value)
}
</script>

<template>
  <view class="reader">
    <!-- Loading State -->
    <view v-if="readerStore.isLoading" class="loading">
      <text>Loading...</text>
    </view>

    <!-- Reading Content -->
    <view
      v-else-if="readerStore.currentBook"
      class="reader-content"
      :class="{ 'toolbar-visible': readerStore.isToolbarVisible }"
    >
      <!-- Page Content -->
      <view class="page-content">
        <text v-if="readerStore.currentPage">
          {{ readerStore.currentPage.content }}
        </text>
        <text v-else class="placeholder">
          Tap center to show controls
        </text>
      </view>

      <!-- Page Indicator -->
      <view class="page-indicator">
        <text class="page-number">
          {{ readerStore.progress.pageIndex + 1 }} / {{ readerStore.totalPages }}
        </text>
        <text class="progress-percent">
          {{ readerStore.progressPercentage }}%
        </text>
      </view>

      <!-- Tap Zones (invisible, for gesture detection) -->
      <view class="tap-zones">
        <view class="tap-zone tap-zone-prev" @tap="readerStore.turnPage('prev')">
          <text v-if="readerStore.isToolbarVisible" class="tap-hint">‹</text>
        </view>
        <view class="tap-zone tap-zone-center" @tap="readerStore.toggleToolbar" />
        <view class="tap-zone tap-zone-next" @tap="readerStore.turnPage('next')">
          <text v-if="readerStore.isToolbarVisible" class="tap-hint">›</text>
        </view>
      </view>
    </view>

    <!-- Toolbar Overlay -->
    <view v-if="readerStore.isToolbarVisible" class="toolbar">
      <!-- Top Bar -->
      <view class="toolbar-top">
        <view class="btn-back" @tap="goBack">
          <text>← Back</text>
        </view>
        <text class="book-title">{{ readerStore.currentBook?.title }}</text>
        <view class="btn-theme" @tap="toggleTheme">
          <text>{{ settingsStore.currentTheme }}</text>
        </view>
      </view>

      <!-- Bottom Bar -->
      <view class="toolbar-bottom">
        <!-- Font Size -->
        <view class="toolbar-group">
          <view class="btn-icon" @tap="adjustFontSize(-2)">
            <text>A-</text>
          </view>
          <text class="font-size-label">{{ settingsStore.settings.font.size }}px</text>
          <view class="btn-icon" @tap="adjustFontSize(2)">
            <text>A+</text>
          </view>
        </view>

        <!-- Progress Slider -->
        <view class="progress-bar">
          <slider
            :value="readerStore.progress.pageIndex"
            :max="readerStore.totalPages - 1"
            :step="1"
            @change="onSliderChange"
          />
        </view>
      </view>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.reader {
  position: relative;
  width: 100vw;
  height: 100vh;
  background-color: var(--bg-color, #ffffff);
  overflow: hidden;
}

.loading {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  font-size: 32rpx;
  color: var(--text-secondary, #666666);
}

.reader-content {
  position: relative;
  width: 100%;
  height: 100%;
  padding: 48rpx 32rpx;
  box-sizing: border-box;
}

.page-content {
  width: 100%;
  height: calc(100% - 60rpx);
  font-family: Georgia, serif;
  font-size: 36rpx;
  line-height: 1.8;
  color: var(--text-color, #1a1a1a);
  overflow: hidden;
}

.placeholder {
  color: var(--text-secondary, #666666);
  font-style: italic;
}

.page-indicator {
  position: absolute;
  bottom: 16rpx;
  left: 0;
  right: 0;
  display: flex;
  justify-content: center;
  gap: 24rpx;
  font-size: 24rpx;
  color: var(--text-secondary, #666666);
}

/* Tap Zones */
.tap-zones {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
}

.tap-zone {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.tap-zone-prev {
  width: 25%;
}

.tap-zone-center {
  width: 50%;
}

.tap-zone-next {
  width: 25%;
}

.tap-hint {
  font-size: 72rpx;
  color: var(--text-secondary, #666666);
  opacity: 0.5;
}

/* Toolbar */
.toolbar {
  position: absolute;
  left: 0;
  right: 0;
  z-index: 100;
}

.toolbar-top {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24rpx 32rpx;
  padding-top: calc(24rpx + env(safe-area-inset-top));
  background: linear-gradient(to bottom, rgba(0, 0, 0, 0.8), transparent);
}

.btn-back,
.btn-theme {
  padding: 12rpx 24rpx;
  color: #ffffff;
  font-size: 28rpx;
}

.book-title {
  color: #ffffff;
  font-size: 28rpx;
  font-weight: 600;
  max-width: 60%;
  text-overflow: ellipsis;
  overflow: hidden;
  white-space: nowrap;
}

.toolbar-bottom {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 24rpx 32rpx;
  padding-bottom: calc(24rpx + env(safe-area-inset-bottom));
  background: linear-gradient(to top, rgba(0, 0, 0, 0.8), transparent);
}

.toolbar-group {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 32rpx;
  margin-bottom: 24rpx;
}

.btn-icon {
  padding: 12rpx 24rpx;
  background-color: rgba(255, 255, 255, 0.2);
  border-radius: 8rpx;
  color: #ffffff;
  font-size: 28rpx;
}

.font-size-label {
  color: #ffffff;
  font-size: 28rpx;
  min-width: 80rpx;
  text-align: center;
}

.progress-bar {
  padding: 0 16rpx;
}
</style>
