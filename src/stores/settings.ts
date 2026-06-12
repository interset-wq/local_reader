/**
 * User settings store — manages reading preferences.
 * Contract: see settings.contract.md
 */

import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { UserSettings, Theme, FontConfig } from '@/types'
import { DEFAULT_SETTINGS } from '@/types'
import { storage } from '@/services/storage-service'

const STORAGE_KEY = 'settings'

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max)
}

export const useSettingsStore = defineStore('settings', () => {
  // State
  const settings = ref<UserSettings>({ ...DEFAULT_SETTINGS })
  const isLoading = ref(false)

  // Getters
  const currentTheme = computed(() => settings.value.theme)
  const currentFont = computed(() => settings.value.font)

  // Actions
  function loadSettings(): void {
    isLoading.value = true
    try {
      const saved = storage.get<Partial<UserSettings>>(STORAGE_KEY)
      if (saved) {
        // Merge with defaults — missing keys get defaults
        settings.value = {
          ...DEFAULT_SETTINGS,
          ...saved,
          font: {
            ...DEFAULT_SETTINGS.font,
            ...(saved.font ?? {}),
          },
        }
      }
    } finally {
      isLoading.value = false
    }
  }

  function persistSettings(): void {
    storage.set(STORAGE_KEY, settings.value)
  }

  function updateSettings(updates: Partial<UserSettings>): void {
    settings.value = { ...settings.value, ...updates }
    persistSettings()
  }

  function resetSettings(): void {
    settings.value = { ...DEFAULT_SETTINGS }
    persistSettings()
  }

  function setTheme(theme: Theme): void {
    settings.value.theme = theme
    persistSettings()
  }

  function setFont(font: Partial<FontConfig>): void {
    settings.value.font = { ...settings.value.font, ...font }
    persistSettings()
  }

  function setFontSize(size: number): void {
    settings.value.font.size = clamp(size, 12, 32)
    persistSettings()
  }

  function setMargins(margins: number): void {
    settings.value.margins = clamp(margins, 8, 48)
    persistSettings()
  }

  return {
    // State
    settings,
    isLoading,

    // Getters
    currentTheme,
    currentFont,

    // Actions
    loadSettings,
    updateSettings,
    resetSettings,
    setTheme,
    setFont,
    setFontSize,
    setMargins,
  }
})
