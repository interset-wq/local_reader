---
name: test-generator
description: Generate Vitest unit tests for functions, composables, and stores. Use when adding new functions or fixing bugs.
---

# Test Generator (Vitest)

## When to Use

- New utility functions
- New composables
- New Pinia stores
- Bug fixes (regression tests)

## Test Structure

```typescript
import { describe, it, expect, vi } from 'vitest'

describe('functionName', () => {
  it('handles normal input', () => {
    expect(functionName(input)).toBe(expected)
  })

  it('handles edge cases', () => {
    expect(functionName(edge)).toBe(expectedEdge)
  })

  it('throws on invalid input', () => {
    expect(() => functionName(invalid)).toThrow()
  })
})
```

## Composable Testing

```typescript
import { describe, it, expect } from 'vitest'
import { useCounter } from '../composables/useCounter'

describe('useCounter', () => {
  it('initializes with default value', () => {
    const { count } = useCounter()
    expect(count.value).toBe(0)
  })

  it('increments', () => {
    const { count, increment } = useCounter()
    increment()
    expect(count.value).toBe(1)
  })
})
```

## uni-app Mocking

```typescript
vi.stubGlobal('uni', {
  getStorageSync: vi.fn(),
  setStorageSync: vi.fn(),
  showToast: vi.fn(),
})
```

## Rules

- One `describe` block per function/composable
- Test names describe behavior, not implementation
- Each test independent — no shared mutable state
- Mock uni-app APIs with `vi.stubGlobal`
