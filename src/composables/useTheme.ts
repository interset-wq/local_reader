/**
 * Composable for applying theme CSS variables to the document.
 */

import { watch, onMounted } from 'vue'
import type { Theme } from '@/types'
import { useSettingsStore } from '@/stores/settings'

const THEME_COLORS: Record<Theme, Record<string, string>> = {
  light: {
    '--bg-color': '#ffffff',
    '--text-color': '#1a1a1a',
    '--text-secondary': '#666666',
    '--border-color': '#e0e0e0',
  },
  dark: {
    '--bg-color': '#1a1a1a',
    '--text-color': '#e0e0e0',
    '--text-secondary': '#999999',
    '--border-color': '#333333',
  },
  sepia: {
    '--bg-color': '#f4ecd8',
    '--text-color': '#5b4636',
    '--text-secondary': '#8b7355',
    '--border-color': '#d4c5a9',
  },
}

export function useTheme() {
  const settingsStore = useSettingsStore()

  function applyTheme(theme: Theme): void {
    const colors = THEME_COLORS[theme]
    const root = document.documentElement

    for (const [key, value] of Object.entries(colors)) {
      root.style.setProperty(key, value)
    }

    // Set meta theme-color for mobile browsers
    const metaTheme = document.querySelector('meta[name="theme-color"]')
    if (metaTheme) {
      metaTheme.setAttribute('content', colors['--bg-color'])
    }
  }

  // Apply on mount
  onMounted(() => {
    applyTheme(settingsStore.currentTheme)
  })

  // Watch for changes
  watch(
    () => settingsStore.currentTheme,
    (newTheme) => {
      applyTheme(newTheme)
    },
  )

  return {
    applyTheme,
  }
}
