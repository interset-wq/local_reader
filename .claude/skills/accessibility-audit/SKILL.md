---
name: accessibility-audit
description: Audit UI for WCAG 2.2 compliance — contrast, touch targets, screen reader support, keyboard navigation. Use when reviewing reader UI or components.
---

# Accessibility Audit (Mobile Reader)

## Focus Areas for AReader

- **Touch targets**: Minimum 44x44dp (iOS) / 48x48dp (Android)
- **Color contrast**: Minimum 4.5:1 for body text, 3:1 for large text
- **Font scaling**: Respect system font size preferences
- **Screen reader**: All interactive elements need accessible labels
- **Reduced motion**: Respect `prefers-reduced-motion`

## Severity Ratings

1. **Critical** — Blocks access entirely (e.g., unlabeled buttons)
2. **Major** — Significant difficulty (e.g., low contrast text)
3. **Minor** — Inconvenience with workarounds
4. **Enhancement** — Beyond compliance

## uni-app Specifics

```html
<!-- Use aria attributes -->
<button aria-label="Next page" @click="nextPage">→</button>

<!-- Semantic roles -->
<view role="document" aria-label="Book content">
  <text>{{ pageContent }}</text>
</view>
```

## Checklist

- [ ] All tappable elements ≥ 44dp
- [ ] Text contrast ≥ 4.5:1
- [ ] No information conveyed by color alone
- [ ] Font size adjustable via system settings
- [ ] Focus order follows reading order
- [ ] Animations respect reduced-motion preference
