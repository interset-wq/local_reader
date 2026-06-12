# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**AReader** is a cross-platform e-book reader app built with uni-app and Vue 3, designed to emulate the reading experience of a Kindle Touch device (2010). The app targets multiple platforms: H5 (web), iOS, Android, and potentially WeChat Mini Program.

## Core Principles

- **Specification-Driven Development** — See [SDD workflow](#specification-driven-development-sdd) below.
- **TypeScript first** — All code in TypeScript. No `.js` files; use `.ts` / `.vue` with `<script lang="ts">`.
- **Offline first** — No network dependency for core reading. Books, progress, and settings stored locally. Sync is a future enhancement, not a requirement.
- **Mobile first** — Design and test for phone screens first. Tablet/desktop are secondary targets.

## Tech Stack

- **Framework**: uni-app (Vue 3 + Composition API + `<script setup>`)
- **Language**: TypeScript
- **UI**: uni-ui components + custom reader UI
- **State**: Pinia
- **Styling**: SCSS
- **Build**: Vite (via @dcloudio/vite-plugin-uni)
- **Package manager**: pnpm (not npm/yarn)
- **Python tooling** (if needed): uv (not pip/venv)

## Project Structure

```
src/
├── pages/              # Route pages (auto-registered from pages.json)
│   ├── index/          # Home/library page
│   └── reader/         # Book reader page
├── components/         # Reusable components
├── stores/             # Pinia stores
├── composables/        # Vue 3 composables (useXxx)
├── types/              # TypeScript type definitions
├── utils/              # Utility functions
├── services/           # Business logic (EPUB parsing, pagination engine)
├── static/             # Static assets (icons, fonts)
├── styles/             # Global SCSS variables/mixins
├── App.vue             # Root component
├── main.ts             # Entry point
├── manifest.json       # uni-app platform config
├── pages.json          # Route definitions
└── uni.scss            # uni-app global style variables
```

## Common Commands

```bash
# Install dependencies
pnpm install

# Run H5 (web) dev server
pnpm dev:h5

# Run on specific platform
pnpm dev:app          # App (HBuilderX required)
pnpm dev:mp-weixin    # WeChat Mini Program

# Build for production
pnpm build:h5
pnpm build:app
pnpm build:mp-weixin

# Type checking
pnpm exec vue-tsc --noEmit

# Lint
pnpm lint
```

## Architecture Notes

- **uni-app conventions**: Pages auto-registered from `pages.json`. Navigation via `uni.navigateTo()`, `uni.switchTab()`. Lifecycle hooks: `onLoad`, `onShow`, `onReady` (not Vue Router).
- **Platform conditionals**: Use `#ifdef` / `#ifndef` preprocessor directives for platform-specific code in templates, scripts, and styles.
- **Composables**: Extract reusable logic into `composables/` as `useXxx()` functions. Keep components thin.
- **Reader core**: Page-based (not scroll-based) UI to mimic Kindle Touch's tap-to-turn-page interaction. EPUB parsing happens client-side.
- **State management**: Pinia stores manage library state, reading progress, and user settings. Persist to `uni.setStorageSync` / `uni.getStorageSync`.
- **Offline storage**: Books stored via `uni.saveFile` to device filesystem. Metadata in Pinia, persisted to local storage. No API calls for core functionality.

## Kindle Touch Design Philosophy

The 2010 Kindle Touch had a deliberately minimal, distraction-free reading experience:
- **Page-based navigation**: Tap left/right edges or swipe to turn pages
- **No scroll**: Content is paginated into fixed "pages"
- **Minimal chrome**: No visible UI during reading; tap center to show toolbar
- **E-ink aesthetic**: High contrast text, minimal color, serif fonts
- **Progress indicator**: Subtle location indicator (e.g., "Location 1234 of 5678")

## Key Implementation Considerations

- **EPUB parsing**: Use `epubjs` or similar library for client-side EPUB rendering
- **Pagination engine**: Content must be measured and split into page-sized chunks; this is the most complex part of the reader
- **Touch handling**: Implement swipe gesture detection for page turns, with tap zones (left 25% = prev, right 25% = next, center 50% = toggle toolbar)
- **Font rendering**: Support adjustable font size, font family, line height, and margins
- **Performance**: Pre-render adjacent pages for instant page turns; lazy-load book content

## Specification-Driven Development (SDD)

This project follows Specification-Driven Development. Every feature starts with a spec before any implementation code is written.

### Workflow

```
1. SPECIFY   → Define types, interfaces, schemas, and contracts
2. VALIDATE  → Review spec with stakeholders / run type checks
3. IMPLEMENT → Write code that satisfies the spec
4. VERIFY    → Tests prove the spec is met
5. ITERATE   → Refine spec based on learnings, repeat
```

### Rules

- **Types first**: Define all TypeScript interfaces/types in `src/types/` before writing any implementation
- **Contracts before code**: Document function signatures, expected inputs/outputs, error cases, and edge cases before implementing
- **Spec = single source of truth**: When spec and implementation conflict, the spec is right — fix the code, not the spec
- **Tests derive from specs**: Every spec requirement maps to at least one test case
- **No implicit behavior**: If it's not in the spec, it's a bug or a spec gap — never an "undocumented feature"
- **Specs are living docs**: Update the spec when requirements change; never let specs go stale

### Spec File Convention

Specs live alongside the code they describe:

```
src/
├── types/
│   ├── book.ts              # Book, BookMetadata, BookFormat types
│   ├── reader.ts            # ReaderState, PagePosition, ReadingProgress
│   └── settings.ts          # UserSettings, Theme, FontConfig
├── services/
│   ├── book-service.ts
│   ├── book-service.spec.ts # Tests derived from spec
│   └── book-service.contract.md  # Behavioral spec (when/why, not just types)
├── composables/
│   ├── usePagination.ts
│   └── usePagination.contract.md
└── stores/
    ├── library.ts
    └── library.contract.md
```

### Contract File Format

Each `.contract.md` file documents:

```markdown
# FeatureName Contract

## Purpose
One sentence: what this module does and why it exists.

## Inputs
- What data flows in, with types and constraints

## Outputs
- What data flows out, with types and guarantees

## Behaviors
- Happy path: what happens under normal conditions
- Edge cases: empty input, max size, boundary values
- Error cases: invalid input, missing data, failures

## Invariants
- What is always true about this module's state

## Dependencies
- What this module depends on, and what depends on it
```

### Development Order

For each feature, follow this sequence:

1. `src/types/xxx.ts` — Define all types and interfaces
2. `src/xxx.contract.md` — Document behaviors, edge cases, invariants
3. `src/xxx.spec.ts` — Write tests that prove the contract
4. `src/xxx.ts` — Implement to satisfy types + tests
5. Run `vue-tsc --noEmit` + `pnpm test` — Verify all pass
