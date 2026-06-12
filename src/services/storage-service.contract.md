# StorageService Contract

## Purpose
Provide a type-safe wrapper around uni-app's storage APIs. Handles serialization/deserialization and provides consistent error handling.

## Inputs
- `key: string` — storage key (namespaced with `areader:` prefix)
- `value: T` — any JSON-serializable value

## Outputs
- `T | null` — deserialized value, or null if not found

## Behaviors

### Happy path
1. `get<T>(key)` — retrieve and deserialize value from storage
2. `set<T>(key, value)` — serialize and store value
3. `remove(key)` — delete key from storage
4. `clear()` — remove all areader-prefixed keys

### Edge cases
- Key not found → return `null` (not undefined)
- Value is `undefined` → store as `null`
- Large values (>1MB) → still store, log warning
- Corrupted data in storage → return `null`, remove corrupted key

### Error cases
- Storage full → throw `StorageError`
- Serialization failure → throw `StorageError`

## Invariants
- All keys are prefixed with `areader:` to avoid conflicts
- Values are always JSON-serialized before storage
- `get` always returns the same type that was `set`, or `null`

## Public API

```typescript
class StorageService {
  get<T>(key: string): T | null
  set<T>(key: string, value: T): void
  remove(key: string): void
  clear(): void
}
```
