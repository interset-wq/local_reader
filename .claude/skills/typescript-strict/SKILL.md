---
name: typescript-strict
description: Enforce strict TypeScript — no `any`, proper generics, discriminated unions, null safety. Use when writing or reviewing TypeScript code.
---

# TypeScript Strict Mode

## Rules

- **No `any`** — use `unknown` and narrow with type guards
- **No `as` assertions** — use runtime validation or generics
- Enable `strict: true`, `noUncheckedIndexedAccess: true`, `noImplicitReturns: true`
- Prefer `interface` for object shapes, `type` for unions/intersections
- Use discriminated unions over optional fields for variant states

## Type Guard Pattern

```typescript
function isBookFile(val: unknown): val is BookFile {
  return typeof val === 'object' && val !== null && 'format' in val
}
```

## Error Handling

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E }

function parseEpub(data: ArrayBuffer): Result<Book> {
  try {
    return { ok: true, value: doParse(data) }
  } catch (e) {
    return { ok: false, error: e instanceof Error ? e : new Error(String(e)) }
  }
}
```

## uni-app Type Augmentation

```typescript
// Extend uni-app types in src/types/uni.d.ts
declare namespace UniApp {
  interface Uni {
    // custom extensions
  }
}
```
