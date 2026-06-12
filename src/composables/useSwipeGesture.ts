/**
 * Composable for swipe gesture detection on the reader screen.
 * Detects tap zones and swipe gestures for page navigation.
 */

import { ref, onMounted, onUnmounted } from 'vue'
import type { TapZone, TurnDirection } from '@/types'

interface SwipeGestureOptions {
  onTapZone?: (zone: TapZone) => void
  onSwipe?: (direction: TurnDirection) => void
  threshold?: number
}

export function useSwipeGesture(options: SwipeGestureOptions = {}) {
  const { onTapZone, onSwipe, threshold = 50 } = options

  const startX = ref(0)
  const startY = ref(0)
  const isDragging = ref(false)

  function getTapZone(x: number, screenWidth: number): TapZone {
    const ratio = x / screenWidth
    if (ratio < 0.25) return 'prev'
    if (ratio > 0.75) return 'next'
    return 'center'
  }

  function handleTouchStart(e: TouchEvent): void {
    const touch = e.touches[0]
    startX.value = touch.clientX
    startY.value = touch.clientY
    isDragging.value = true
  }

  function handleTouchEnd(e: TouchEvent): void {
    if (!isDragging.value) return
    isDragging.value = false

    const touch = e.changedTouches[0]
    const deltaX = touch.clientX - startX.value
    const deltaY = touch.clientY - startY.value
    const screenWidth = window.innerWidth

    // Check for swipe (horizontal movement > threshold)
    if (Math.abs(deltaX) > threshold && Math.abs(deltaX) > Math.abs(deltaY)) {
      onSwipe?.(deltaX > 0 ? 'prev' : 'next')
      return
    }

    // Check for tap (minimal movement)
    if (Math.abs(deltaX) < 10 && Math.abs(deltaY) < 10) {
      const zone = getTapZone(touch.clientX, screenWidth)
      onTapZone?.(zone)
    }
  }

  function handleTouchMove(e: TouchEvent): void {
    // Prevent default to avoid scrolling
    if (isDragging.value) {
      e.preventDefault()
    }
  }

  onMounted(() => {
    document.addEventListener('touchstart', handleTouchStart, { passive: true })
    document.addEventListener('touchend', handleTouchEnd, { passive: true })
    document.addEventListener('touchmove', handleTouchMove, { passive: false })
  })

  onUnmounted(() => {
    document.removeEventListener('touchstart', handleTouchStart)
    document.removeEventListener('touchend', handleTouchEnd)
    document.removeEventListener('touchmove', handleTouchMove)
  })

  return {
    isDragging,
  }
}
