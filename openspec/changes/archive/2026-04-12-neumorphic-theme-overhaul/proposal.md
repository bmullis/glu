## Why

Glu's current UI is functional but uses hardcoded dark-only styling with no design system. Adopting a neumorphic visual language will give the app a distinctive, modern feel that stands out from typical flat macOS utilities, while introducing a proper theme system (light/dark/system) makes the app feel native and accessible to users regardless of their system preferences.

## What Changes

- Replace all inline color/shadow/styling with a centralized design token system that supports light, dark, and system-matched themes
- Restyle the panel background, search bar, cards, and all UI elements to follow neumorphic design principles (soft shadows, subtle gradients, extruded/inset surfaces)
- Add a theme toggle control to the toolbar area (light / dark / system) that persists across launches
- Introduce reusable SwiftUI view modifiers and color extensions for consistent neumorphic styling across components

## Capabilities

### New Capabilities
- `theme-system`: Centralized theme engine with light/dark/system modes, design tokens (colors, shadows, radii), persistence of user preference, and reactive theme switching
- `neumorphic-components`: Neumorphic visual styling for all UI surfaces including panel background, search bar, clipboard cards, toolbar, and empty state

### Modified Capabilities
None - no existing specs to modify.

## Impact

- **Views**: All four view files (`PanelContentView`, `ClipboardCardView`, `PanelWindow`, `PanelWindowController`) will be restyled
- **New files**: Theme definition module (colors, shadows, tokens), SwiftUI view modifiers for neumorphic effects, theme toggle view
- **App entry**: `GluApp.swift` will need to initialize and propagate the theme environment
- **Persistence**: User's theme preference (light/dark/system) needs to be stored via `UserDefaults` or similar
- **Dependencies**: No new external dependencies required; uses native SwiftUI and AppKit APIs
