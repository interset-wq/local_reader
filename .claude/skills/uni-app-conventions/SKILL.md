---
name: uni-app-conventions
description: uni-app + Vue 3 + TypeScript conventions for AReader. Use when creating pages, components, or working with platform-specific code.
---

# uni-app Conventions (AReader)

## Project Rules

- **TypeScript only** — `.ts` files, `<script setup lang="ts">`
- **pnpm** — not npm or yarn
- **Offline first** — no network calls for core reading functionality
- **Mobile first** — design for 375px width, scale up

## Page Structure

Pages are auto-registered from `src/pages.json`. Each page is a directory:

```
src/pages/reader/
├── reader.vue          # Page component
├── components/         # Page-local components
└── composables/        # Page-local composables
```

## Navigation

```typescript
// Push to page with params
uni.navigateTo({ url: '/pages/reader/reader?bookId=123' })

// Tab switching
uni.switchTab({ url: '/pages/index/index' })

// Back
uni.navigateBack()
```

## Platform Conditionals

```html
<template>
  <!-- #ifdef H5 -->
  <div class="web-only">Web version</div>
  <!-- #endif -->

  <!-- #ifdef APP-PLUS -->
  <view class="app-only">App version</view>
  <!-- #endif -->
</template>

<script setup lang="ts">
// #ifdef APP-PLUS
import { plus } from 'uni-app-plus'
// #endif
</script>
```

## File Naming

- Pages: `kebab-case.vue` (e.g., `book-detail.vue`)
- Components: `PascalCase.vue` (e.g., `PageSlider.vue`)
- Composables: `useXxx.ts` (e.g., `useBookLoader.ts`)
- Stores: `useXxxStore.ts` (e.g., `useLibraryStore.ts`)
- Types: `kebab-case.ts` in `src/types/`

## Styling

- Use `rpx` units for responsive sizing (1rpx = 0.5px on 750px design)
- Global variables in `src/styles/variables.scss`
- Component styles as `<style lang="scss" scoped>`

## Storage

```typescript
// Synchronous (small data)
uni.setStorageSync('settings', { fontSize: 16 })
const settings = uni.getStorageSync('settings')

// Async (large data / files)
uni.saveFile({ tempFilePath, success: (res) => { /* */ } })
```
