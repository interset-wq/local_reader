/**
 * User settings types for AReader.
 * Defines all configurable reading preferences.
 */

/** Available themes */
export type Theme = 'light' | 'dark' | 'sepia'

/** Font configuration */
export interface FontConfig {
  family: string
  size: number
  lineHeight: number
}

/** Complete user settings */
export interface UserSettings {
  theme: Theme
  font: FontConfig
  margins: number
  brightness: number
  turnPageAnimation: boolean
}

/** Default settings values */
export const DEFAULT_SETTINGS: UserSettings = {
  theme: 'light',
  font: {
    family: 'Georgia, serif',
    size: 18,
    lineHeight: 1.6,
  },
  margins: 24,
  brightness: 100,
  turnPageAnimation: true,
} as const
