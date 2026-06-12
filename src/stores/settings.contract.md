# useSettingsStore Contract

## Purpose
Manage user reading preferences — theme, font, margins, brightness. Settings persist across sessions.

## State

```typescript
interface SettingsState {
  settings: UserSettings
  isLoading: boolean
}
```

## Behaviors

### Actions
- `loadSettings()` — load from storage, apply defaults for missing keys
- `updateSettings(updates: Partial<UserSettings>)` — merge updates, persist, apply
- `resetSettings()` — restore all settings to defaults
- `setTheme(theme: Theme)` — change theme, apply immediately
- `setFont(font: Partial<FontConfig>)` — update font config
- `setFontSize(size: number)` — adjust font size (clamp 12-32)
- `setMargins(margins: number)` — adjust margins (clamp 8-48)

### Getters
- `currentTheme` — current theme value
- `currentFont` — current font config
- `cssVariables` — CSS custom properties for current settings

### Edge cases
- No saved settings → use `DEFAULT_SETTINGS`
- Partial saved settings → merge with defaults (missing keys get defaults)
- Font size out of range → clamp to 12-32
- Margins out of range → clamp to 8-48

### Invariants
- `settings` always has all required fields (never partial)
- Settings are persisted after every mutation
- Theme changes apply CSS variables immediately

## Dependencies
- `StorageService` — persistence
