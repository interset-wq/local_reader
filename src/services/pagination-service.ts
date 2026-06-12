/**
 * Pagination service — splits content into page-sized chunks.
 * Contract: see pagination-service.contract.md
 */

import type { FontConfig, RenderedPage } from '@/types'

export class PaginationService {
  /**
   * Paginate chapter content into pages that fit the viewport.
   * Uses binary search to find the optimal split point.
   */
  paginate(
    content: string,
    viewportWidth: number,
    viewportHeight: number,
    fontConfig: FontConfig,
    margins: number,
  ): RenderedPage[] {
    if (viewportWidth <= 0 || viewportHeight <= 0) {
      throw new Error('Viewport dimensions must be positive')
    }
    if (fontConfig.size <= 0) {
      throw new Error('Font size must be positive')
    }
    if (!content.trim()) {
      return [{ content: '', pageIndex: 0, chapterIndex: 0 }]
    }

    // Create a hidden container for measurement
    const container = this.createMeasureContainer(viewportWidth, viewportHeight, fontConfig, margins)
    document.body.appendChild(container)

    try {
      return this.splitContent(content, container, viewportHeight)
    } finally {
      document.body.removeChild(container)
    }
  }

  /**
   * Re-paginate when settings change.
   */
  repaginate(
    content: string,
    viewportWidth: number,
    viewportHeight: number,
    fontConfig: FontConfig,
    margins: number,
  ): RenderedPage[] {
    return this.paginate(content, viewportWidth, viewportHeight, fontConfig, margins)
  }

  // --- Private helpers ---

  private createMeasureContainer(
    width: number,
    height: number,
    fontConfig: FontConfig,
    margins: number,
  ): HTMLDivElement {
    const container = document.createElement('div')
    container.style.cssText = `
      position: absolute;
      top: -9999px;
      left: -9999px;
      width: ${width - margins * 2}px;
      height: ${height}px;
      overflow: hidden;
      font-family: ${fontConfig.family};
      font-size: ${fontConfig.size}px;
      line-height: ${fontConfig.lineHeight};
      padding: 0 ${margins}px;
      box-sizing: border-box;
    `
    return container
  }

  private splitContent(
    content: string,
    container: HTMLDivElement,
    maxHeight: number,
  ): RenderedPage[] {
    const pages: RenderedPage[] = []
    const wrapper = document.createElement('div')
    container.appendChild(wrapper)

    // Split content into blocks (paragraphs, headings, etc.)
    const blocks = this.extractBlocks(content)
    let currentContent = ''
    let pageIndex = 0

    for (const block of blocks) {
      // Try adding this block
      const testContent = currentContent + block
      wrapper.innerHTML = testContent

      if (wrapper.scrollHeight <= maxHeight) {
        // Block fits — add it
        currentContent = testContent
      } else {
        // Block doesn't fit
        if (currentContent) {
          // Save current page
          pages.push({
            content: currentContent,
            pageIndex,
            chapterIndex: 0,
          })
          pageIndex++
          currentContent = ''
        }

        // Check if block itself fits on one page
        wrapper.innerHTML = block
        if (wrapper.scrollHeight <= maxHeight) {
          currentContent = block
        } else {
          // Block is too large — split at word boundaries
          const subPages = this.splitLargeBlock(block, wrapper, maxHeight)
          for (let i = 0; i < subPages.length - 1; i++) {
            pages.push({
              content: subPages[i],
              pageIndex,
              chapterIndex: 0,
            })
            pageIndex++
          }
          currentContent = subPages[subPages.length - 1]
        }
      }
    }

    // Add remaining content
    if (currentContent) {
      pages.push({
        content: currentContent,
        pageIndex,
        chapterIndex: 0,
      })
    }

    // Clean up
    container.removeChild(wrapper)

    return pages.length > 0 ? pages : [{ content: '', pageIndex: 0, chapterIndex: 0 }]
  }

  private extractBlocks(html: string): string[] {
    // Split by block-level elements
    const temp = document.createElement('div')
    temp.innerHTML = html
    const blocks: string[] = []

    for (const child of Array.from(temp.childNodes)) {
      if (child.nodeType === Node.ELEMENT_NODE) {
        blocks.push((child as Element).outerHTML)
      } else if (child.nodeType === Node.TEXT_NODE && child.textContent?.trim()) {
        blocks.push(`<p>${child.textContent}</p>`)
      }
    }

    return blocks.length > 0 ? blocks : [html]
  }

  private splitLargeBlock(
    block: string,
    wrapper: HTMLDivElement,
    maxHeight: number,
  ): string[] {
    const pages: string[] = []
    const temp = document.createElement('div')
    temp.innerHTML = block
    const text = temp.textContent ?? ''
    const words = text.split(/\s+/)

    let current = ''
    for (const word of words) {
      const test = current ? `${current} ${word}` : word
      wrapper.innerHTML = `<p>${test}</p>`

      if (wrapper.scrollHeight > maxHeight && current) {
        pages.push(`<p>${current}</p>`)
        current = word
      } else {
        current = test
      }
    }

    if (current) {
      pages.push(`<p>${current}</p>`)
    }

    return pages.length > 0 ? pages : [block]
  }
}

/** Singleton instance */
export const paginationService = new PaginationService()
