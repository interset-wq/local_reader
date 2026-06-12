# PaginationService Contract

## Purpose
Split book content into page-sized chunks for the Kindle-style page-based reading experience. Content must be measured and split to fit the viewport exactly — no scrolling.

## Inputs
- `content: string` — HTML content of a chapter
- `viewportWidth: number` — available width in pixels
- `viewportHeight: number` — available height in pixels
- `fontConfig: FontConfig` — font family, size, line height
- `margins: number` — horizontal margins in pixels

## Outputs
- `RenderedPage[]` — array of HTML content chunks, each fitting exactly one page

## Behaviors

### Happy path
1. Measure total content height using a hidden container
2. Split content at word/element boundaries (never mid-word)
3. Each page fills the viewport exactly — no overflow, no scroll
4. Preserve HTML structure (paragraphs, headings, lists) across page breaks
5. Return ordered array of pages

### Edge cases
- Content shorter than one page → single page with all content
- Content with images → split around images, never cut an image
- Content with very long paragraphs → split at sentence boundaries
- Content with tables → keep tables on one page if possible, split rows if needed
- Empty content → return single empty page

### Error cases
- Invalid HTML content → still attempt to render, log warning
- Viewport dimensions <= 0 → throw error with message
- Font size <= 0 → throw error with message

## Invariants
- Total text across all pages equals original content (no content loss)
- Each page's content fits within viewport dimensions
- Pages are ordered sequentially
- No page is empty unless the source content is empty
- Page breaks occur only at word/sentence/element boundaries

## Dependencies
- DOM measurement (create temporary container, measure content height)
- No external libraries needed — pure DOM manipulation

## Public API

```typescript
class PaginationService {
  /** Paginate chapter content into pages */
  paginate(
    content: string,
    viewportWidth: number,
    viewportHeight: number,
    fontConfig: FontConfig,
    margins: number,
  ): RenderedPage[]

  /** Re-paginate when settings change (font size, margins, etc.) */
  repaginate(
    content: string,
    viewportWidth: number,
    viewportHeight: number,
    fontConfig: FontConfig,
    margins: number,
  ): RenderedPage[]
}
```
