## Context

Glu is a macOS clipboard manager built with SwiftUI + AppKit. The UI is a bottom-anchored floating panel with a search bar and horizontally scrolling clipboard cards. All styling is currently hardcoded inline across four view files with no centralized design system. Colors are dark-only, using raw `NSColor(white:)` and SwiftUI `.white` with opacity modifiers. There is no theme infrastructure, no reusable style components, and no user preference for appearance.

## Goals / Non-Goals

**Goals:**
- Establish a centralized theme system with design tokens (colors, shadows, spacing) that all views consume
- Support three appearance modes: light, dark, and system (follows macOS appearance)
- Persist the user's theme preference across launches
- Restyle all UI surfaces with neumorphic design principles: soft dual shadows (light + dark), subtle surface gradients, extruded and inset effects
- Add a theme toggle to the toolbar/panel header area
- Keep the app feeling lightweight and fast with no new dependencies

**Non-Goals:**
- Custom user-defined themes or accent color pickers
- Animated theme transitions (switching is instant)
- Redesigning the layout, card dimensions, or interaction model
- Adding a full settings/preferences window
- Supporting macOS versions below 14.0

## Decisions

### 1. Theme token architecture: SwiftUI Environment + ObservableObject

The theme will be an `@Observable` class (`ThemeManager`) injected into the SwiftUI environment. It exposes computed color/shadow properties that react to the current mode. Views read tokens like `theme.cardBackground` and `theme.neuShadowLight` rather than hardcoded values.

**Why over alternatives:**
- *Static color assets (xcassets)*: Can't express neumorphic dual-shadow pairs or complex computed styles. Limited to simple color adaptation.
- *ViewModifier-only approach*: Modifiers are part of the solution but need a backing token system to draw from.

### 2. Theme persistence: UserDefaults with raw string key

Store the selected mode (`"light"`, `"dark"`, `"system"`) in `UserDefaults.standard` under a `"glu.themeMode"` key. On launch, `ThemeManager` reads this value and falls back to `"system"`.

**Why over alternatives:**
- *SwiftData*: Overkill for a single preference string, and introduces schema coupling for non-model data.
- *@AppStorage*: Would work but ties persistence to a specific SwiftUI view's lifecycle. Using UserDefaults directly gives `ThemeManager` full control.

### 3. System appearance tracking: NSApp.effectiveAppearance observation

When mode is `"system"`, `ThemeManager` observes `NSApp.effectiveAppearance` via KVO to detect macOS light/dark changes and update tokens reactively.

**Why over alternatives:**
- *SwiftUI `@Environment(\.colorScheme)`*: Only available inside SwiftUI views, not in the standalone manager class. The manager needs to know the resolved scheme to compute tokens.

### 4. Neumorphic styling via paired ViewModifiers

Create two primary modifiers: `.neuExtruded()` for raised surfaces (cards, buttons) and `.neuInset()` for recessed surfaces (search bar, input fields). Each applies the appropriate dual-shadow pair (top-left light, bottom-right dark) and surface gradient for the current theme.

**Why over alternatives:**
- *Per-component inline styling*: This is what we have now and it's the problem. Modifiers keep styling DRY and theme-reactive.
- *Shape styles / custom shapes*: Too rigid for varying corner radii and component shapes across the UI.

### 5. Theme toggle: SF Symbol button in the toolbar row

A small button using SF Symbols (`sun.max.fill`, `moon.fill`, `circle.lefthalf.filled`) placed in the panel's top-right toolbar area. Tapping cycles through light/dark/system. The icon reflects the current active mode.

**Why over alternatives:**
- *Dropdown menu*: Three options don't warrant a dropdown; a cycle button is more compact for the minimal toolbar space.
- *Segmented control*: Takes more horizontal space and adds visual weight to the toolbar.

## Risks / Trade-offs

- **Neumorphic contrast on light backgrounds**: Neumorphism can suffer from low contrast on very light surfaces, making text hard to read. Mitigation: use a warm off-white base (not pure white) and ensure text colors meet WCAG AA contrast ratios.
- **Performance of dual shadows**: Each neumorphic element renders two shadow layers. Mitigation: use `.drawingGroup()` on the card scroller if profiling shows shadow compositing overhead in the LazyHStack.
- **Visual consistency across macOS versions**: Material effects and shadow rendering can vary slightly between macOS 14 and 15. Mitigation: test on both, use solid color fallbacks where materials behave unexpectedly.
