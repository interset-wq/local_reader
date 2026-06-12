import { describe, it, expect, beforeEach, vi } from 'vitest'
import { StorageService } from './storage-service'

// Mock uni storage
const mockStorage: Record<string, string> = {}
vi.stubGlobal('uni', {
  getStorageSync: vi.fn((key: string) => mockStorage[key] ?? ''),
  setStorageSync: vi.fn((key: string, value: string) => { mockStorage[key] = value }),
  removeStorageSync: vi.fn((key: string) => { delete mockStorage[key] }),
})

describe('StorageService', () => {
  let storage: StorageService

  beforeEach(() => {
    storage = new StorageService()
    // Clear mock storage
    for (const key of Object.keys(mockStorage)) {
      delete mockStorage[key]
    }
    vi.clearAllMocks()
  })

  describe('get', () => {
    it('returns null for non-existent key', () => {
      expect(storage.get('nonexistent')).toBeNull()
    })

    it('returns stored value', () => {
      storage.set('test', { foo: 'bar' })
      expect(storage.get('test')).toEqual({ foo: 'bar' })
    })

    it('returns null for corrupted data', () => {
      mockStorage['areader:corrupted'] = 'not-valid-json'
      expect(storage.get('corrupted')).toBeNull()
    })
  })

  describe('set', () => {
    it('stores value with areader: prefix', () => {
      storage.set('mykey', 'myvalue')
      expect(uni.setStorageSync).toHaveBeenCalledWith('areader:mykey', '"myvalue"')
    })

    it('stores complex objects', () => {
      const obj = { a: 1, b: [2, 3] }
      storage.set('complex', obj)
      expect(storage.get('complex')).toEqual(obj)
    })
  })

  describe('remove', () => {
    it('removes stored key', () => {
      storage.set('todelete', 'value')
      storage.remove('todelete')
      expect(storage.get('todelete')).toBeNull()
    })
  })
})
