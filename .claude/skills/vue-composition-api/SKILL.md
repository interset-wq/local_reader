---
name: vue-composition-api
description: Vue 3 Composition API patterns for uni-app — composables, reactivity, script setup, provide/inject. Use when creating components, composables, or stores.
---

# Vue Composition API (uni-app)

## Rules

- Always use `<script setup lang="ts">` — never Options API
- Use `ref()` for primitives, `reactive()` for objects
- Extract reusable logic into `composables/useXxx.ts`
- Return `readonly(state)` from composables to prevent external mutation
- Clean up side effects in `onUnmounted()`

## Composable Anatomy

```typescript
// composables/useFeature.ts
export function useFeature(options?: Options) {
  const state = ref(initialValue)
  const derived = computed(() => transform(state.value))
  function action() { /* ... */ }
  onMounted(() => { /* setup */ })
  onUnmounted(() => { /* cleanup */ })
  return { state: readonly(state), derived, action }
}
```

## uni-app Lifecycle

uni-app uses its own lifecycle hooks alongside Vue's:
- `onLoad(query)` — page loaded (replaces `created` for pages)
- `onShow` — page shown (fired on every navigation to page)
- `onReady` — page first render complete
- `onHide` — page hidden
- `onUnload` — page destroyed

Vue lifecycle `onMounted`/`onUnmounted` also work but `onLoad`/`onUnload` are preferred for page-level logic.

## Common Patterns

```typescript
// Local storage sync
export function usePersistedState<T>(key: string, defaultValue: T) {
  const stored = uni.getStorageSync(key)
  const state = ref<T>(stored ?? defaultValue)
  watch(state, (val) => uni.setStorageSync(key, val), { deep: true })
  return state
}
```

## Resources

- [Vue Composition API Guide](https://vuejs.org/guide/extras/composition-api-faq.html)
- [VueUse](https://vueuse.org/) — composable utilities
