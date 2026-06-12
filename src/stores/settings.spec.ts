import { describe, it, expect, beforeEach, vi } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useSettingsStore } from './settings'
import { DEFAULT_SETTINGS } from '@/types'

// Mock uni storage
const mockStorage: Record<string, string> = {}
vi.stubGlobal('uni', {
  getStorageSync: vi.fn((key: string) => mockStorage[key] ?? ''),
  setStorageSync: vi.fn((key: string, value: string) => { mockStorage[key] = value }),
  removeStorageSync: vi.fn((key: string) => { delete mockStorage[key] }),
})

describe('useSettingsStore', () => {
  let store: ReturnType<typeof useSettingsStore>

  beforeEach(() => {
    setActivePinia(createPinia())
    for (const key of Object.keys(mockStorage)) {
      delete mockStorage[key]
    }
    vi.clearAllMocks()
    store = useSettingsStore()
  })

  describe('defaults', () => {
    it('uses DEFAULT_SETTINGS when no saved settings exist', () => {
      expect(store.settings).toEqual(DEFAULT_SETTINGS)
    })

    it('has light theme by default', () => {
      expect(store.settings.theme).toBe('light')
    })
  })

  describe('setTheme', () => {
    it('changes theme to dark', () => {
      store.setTheme('dark')
      expect(store.settings.theme).toBe('dark')
    })

    it('changes theme to sepia', () => {
      store.setTheme('sepia')
      expect(store.settings.theme).toBe('sepia')
    })
  })

  describe('setFontSize', () => {
    it('sets font size within valid range', () => {
      store.setFontSize(20)
      expect(store.settings.font.size).toBe(20)
    })

    it('clamps font size to minimum 12', () => {
      store.setFontSize(8)
      expect(store.settings.font.size).toBe(12)
    })

    it('clamps font size to maximum 32', () => {
      store.setFontSize(40)
      expect(store.settings.font.size).toBe(32)
    })
  })

  describe('setMargins', () => {
    it('sets margins within valid range', () => {
      store.setMargins(16)
      expect(store.settings.margins).toBe(16)
    })

    it('clamps margins to minimum 8', () => {
      store.setMargins(2)
      expect(store.settings.margins).toBe(8)
    })

    it('clamps margins to maximum 48', () => {
      store.setMargins(100)
      expect(store.settings.margins).toBe(48)
    })
  })

  describe('resetSettings', () => {
    it('restores all settings to defaults', () => {
      store.setTheme('dark')
      store.setFontSize(24)
      store.resetSettings()
      expect(store.settings).toEqual(DEFAULT_SETTINGS)
    })
  })
})
