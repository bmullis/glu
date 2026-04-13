## 1. Theme System Foundation

- [x] 1.1 Create `ThemeMode` enum (light, dark, system) and `ThemeManager` @Observable class with UserDefaults persistence under `"glu.themeMode"` key, defaulting to system
- [x] 1.2 Define design token properties on `ThemeManager`: primary background, card background, search bar background, text primary/secondary/tertiary, accent, divider, neumorphic light shadow, neumorphic dark shadow
- [x] 1.3 Implement system appearance tracking via KVO on `NSApp.effectiveAppearance` so tokens update reactively when macOS appearance changes in system mode
- [x] 1.4 Inject `ThemeManager` into the SwiftUI environment from `GluApp.swift` so all views can access it

## 2. Neumorphic View Modifiers

- [x] 2.1 Create `.neuExtruded()` SwiftUI view modifier that applies dual outer shadows (light top-left, dark bottom-right) reading colors and offsets from the active theme
- [x] 2.2 Create `.neuInset()` SwiftUI view modifier that applies dual inner shadows (dark top-left, light bottom-right) reading colors and offsets from the active theme
- [x] 2.3 Create SwiftUI `Color` extensions for theme token convenience accessors

## 3. Panel and Toolbar Restyling

- [x] 3.1 Update `PanelWindow.swift` to use theme-aware panel background color instead of hardcoded values
- [x] 3.2 Refactor `PanelContentView.swift` toolbar area: replace the divider with a subtly differentiated surface tone, add the theme toggle button in the top-right
- [x] 3.3 Implement the theme toggle button view with SF Symbol icons (sun.max.fill / moon.fill / circle.lefthalf.filled) that cycles through system, light, dark on tap

## 4. Search Bar Restyling

- [x] 4.1 Apply `.neuInset()` modifier to the search bar in `PanelContentView.swift` and replace hardcoded colors with theme tokens for text, icon, and background

## 5. Card Restyling

- [x] 5.1 Update `ClipboardCardView.swift` to use `.neuExtruded()` for the card surface and replace all hardcoded colors with theme tokens (card background, text primary/secondary, border, shadows)
- [x] 5.2 Update selected card state to intensify neumorphic shadow depth and show accent border using theme tokens

## 6. Empty State and Remaining Elements

- [x] 6.1 Update empty state text and icon in `PanelContentView.swift` to use theme text tokens
- [x] 6.2 Update URL-type card text color and file-type card icon color to use theme-aware values
- [x] 6.3 Remove all remaining hardcoded color literals from view files, ensuring every color reference reads from the theme system

## 7. Verification

- [x] 7.1 Build and run the app, verify neumorphic appearance in dark mode
- [ ] 7.2 Toggle to light mode, verify all surfaces, text, and shadows adapt correctly
- [ ] 7.3 Toggle to system mode, change macOS appearance, verify reactive switching
- [ ] 7.4 Quit and relaunch the app, verify the previously selected theme mode persists
