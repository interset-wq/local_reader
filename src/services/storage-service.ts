/**
 * Type-safe storage service wrapper for uni-app storage APIs.
 * Contract: see storage-service.contract.md
 */

import { StorageError } from '@/types/errors'

const KEY_PREFIX = 'areader:'

export class StorageService {
  /**
   * Retrieve and deserialize a value from storage.
   * Returns null if key not found or data is corrupted.
   */
  get<T>(key: string): T | null {
    try {
      const raw = uni.getStorageSync(this.prefixedKey(key))
      if (!raw || typeof raw !== 'string') {
        return null
      }
      return JSON.parse(raw) as T
    } catch {
      // Corrupted data — remove it
      this.remove(key)
      return null
    }
  }

  /**
   * Serialize and store a value.
   */
  set<T>(key: string, value: T): void {
    try {
      const serialized = JSON.stringify(value)
      uni.setStorageSync(this.prefixedKey(key), serialized)
    } catch (e) {
      throw new StorageError(
        `Failed to store key "${key}": ${e instanceof Error ? e.message : String(e)}`,
      )
    }
  }

  /**
   * Remove a key from storage.
   */
  remove(key: string): void {
    try {
      uni.removeStorageSync(this.prefixedKey(key))
    } catch {
      // Ignore removal errors
    }
  }

  /**
   * Clear all areader-prefixed keys from storage.
   */
  clear(): void {
    try {
      const res = uni.getStorageInfoSync()
      const keys = res.keys.filter((k: string) => k.startsWith(KEY_PREFIX))
      for (const key of keys) {
        uni.removeStorageSync(key)
      }
    } catch {
      // Ignore clear errors
    }
  }

  private prefixedKey(key: string): string {
    return `${KEY_PREFIX}${key}`
  }
}

/** Singleton instance */
export const storage = new StorageService()
