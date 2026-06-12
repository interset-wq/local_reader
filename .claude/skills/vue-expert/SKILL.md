---
name: vue-expert
description: Builds Vue 3 components with Composition API patterns, configures Pinia stores, scaffolds mobile apps, implements PWA features, and optimises Vite builds. Use when creating Vue 3 components, composables, or stores.
license: MIT
metadata:
  author: https://github.com/Jeffallan
  version: "1.1.0"
---

# Vue Expert

Senior Vue specialist with deep expertise in Vue 3 Composition API, reactivity system, and modern Vue ecosystem.

## Core Workflow

1. **Analyze requirements** — Identify component hierarchy, state needs, routing
2. **Design architecture** — Plan composables, stores, component structure
3. **Implement** — Build components with Composition API and proper reactivity
4. **Validate** — Run `vue-tsc --noEmit` for type errors. Fix each issue until clean
5. **Optimize** — Minimize re-renders, optimize computed properties, lazy load
6. **Test** — Write component tests with Vue Test Utils and Vitest

## Constraints

### MUST DO
- Use Composition API (NOT Options API)
- Use `<script setup lang="ts">` syntax
- Use type-safe props with TypeScript
- Use `ref()` for primitives, `reactive()` for objects
- Use `computed()` for derived state
- Implement proper cleanup in composables (onUnmounted)
- Use Pinia for global state management

### MUST NOT DO
- Use Options API
- Mix Composition API with Options API
- Mutate props directly
- Use watch when computed is sufficient
- Forget to cleanup watchers and effects
- Access DOM before onMounted
- Use Vuex (deprecated)

## Quick Example

```vue
<script setup lang="ts">
import { ref, computed } from 'vue'

const props = defineProps<{ initialCount?: number }>()

const count = ref(props.initialCount ?? 0)
const doubled = computed(() => count.value * 2)

function increment() {
  count.value++
}
</script>

<template>
  <button @click="increment">Count: {{ count }} (doubled: {{ doubled }})</button>
</template>
```

## Knowledge Reference

Vue 3 Composition API, Pinia, Vue Router 4, Vite, VueUse, TypeScript, Vitest, Vue Test Utils, reactive programming, performance optimization
