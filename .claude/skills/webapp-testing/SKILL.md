---
name: webapp-testing
description: Toolkit for interacting with and testing local web applications using Playwright. Supports verifying frontend functionality, debugging UI behavior, capturing browser screenshots, and viewing browser logs.
license: Anthropic — Complete terms in LICENSE.txt
---

# Web Application Testing

To test local web applications, write native Python Playwright scripts.

## Decision Tree

- Is it static HTML? → Read HTML file directly to identify selectors
- Is the server already running?
  - No → Run server first
  - Yes → Reconnaissance-then-action:
    1. Navigate and wait for networkidle
    2. Take screenshot or inspect DOM
    3. Identify selectors from rendered state
    4. Execute actions with discovered selectors

## Best Practices

- Use sync_playwright() for synchronous scripts
- Always close the browser when done
- Use descriptive selectors: text=, role=, CSS selectors, or IDs
- Add appropriate waits (prefer auto-waiting over explicit timeouts)

## Playwright + Vitest Integration

For E2E tests alongside unit tests:

```typescript
import { test, expect } from '@playwright/test'

test('reader loads book', async ({ page }) => {
  await page.goto('/reader?bookId=test')
  await expect(page.getByRole('document')).toBeVisible()
})
```

## uni-app H5 Testing

For testing uni-app H5 builds with Playwright:

```typescript
test('page navigation works', async ({ page }) => {
  await page.goto('http://localhost:5173')
  await page.getByText('My Book').click()
  await expect(page).toHaveURL(/reader/)
})
```
