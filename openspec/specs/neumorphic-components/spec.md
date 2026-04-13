## ADDED Requirements

### Requirement: Neumorphic panel background
The panel background SHALL use a soft, matte surface color from the theme tokens with a subtle inner glow effect. In dark mode the base SHALL be a deep neutral gray. In light mode the base SHALL be a warm off-white. The panel SHALL retain its existing corner radius and material blur behavior.

#### Scenario: Dark mode panel appearance
- **WHEN** the panel renders in dark mode
- **THEN** the background uses a deep neutral gray surface with soft neumorphic shadow edges

#### Scenario: Light mode panel appearance
- **WHEN** the panel renders in light mode
- **THEN** the background uses a warm off-white surface with soft neumorphic shadow edges

### Requirement: Neumorphic card styling
Each clipboard card SHALL appear as an extruded neumorphic surface with dual shadows: a light shadow offset toward the top-left and a dark shadow offset toward the bottom-right. The card background SHALL use the card background token. The selected card SHALL intensify its shadow depth and display an accent-colored border. Cards SHALL retain their existing 280x280 dimensions and 12pt corner radius.

#### Scenario: Unselected card in dark mode
- **WHEN** a card renders unselected in dark mode
- **THEN** it displays with a raised appearance using a lighter shadow on the top-left and a darker shadow on the bottom-right relative to the dark surface

#### Scenario: Selected card
- **WHEN** a card is selected
- **THEN** the dual shadow depth increases and an accent-colored border appears

#### Scenario: Unselected card in light mode
- **WHEN** a card renders unselected in light mode
- **THEN** it displays with a raised appearance using a white shadow on the top-left and a medium gray shadow on the bottom-right relative to the light surface

### Requirement: Neumorphic search bar
The search bar SHALL appear as an inset neumorphic surface, visually recessed into the panel background. This is achieved with an inverted dual-shadow pair: dark shadow on the top-left (inner), light shadow on the bottom-right (inner). The search bar background SHALL use the search bar background token.

#### Scenario: Search bar in dark mode
- **WHEN** the search bar renders in dark mode
- **THEN** it appears recessed with inner shadows creating a subtle inset effect against the dark panel surface

#### Scenario: Search bar in light mode
- **WHEN** the search bar renders in light mode
- **THEN** it appears recessed with inner shadows creating a subtle inset effect against the light panel surface

### Requirement: Neumorphic toolbar area
The panel SHALL include a toolbar row at the top containing the search bar and the theme toggle button. The toolbar area SHALL use a slightly differentiated surface tone from the main panel background to create visual separation without a hard divider line.

#### Scenario: Toolbar visual separation
- **WHEN** the panel renders
- **THEN** the toolbar area is visually distinct from the card scroll area through a subtle surface tone difference rather than a line divider

### Requirement: Text contrast compliance
All text rendered on neumorphic surfaces SHALL maintain sufficient contrast for readability. Primary text SHALL use the text primary token, secondary text (timestamps, app names) SHALL use the text secondary token. Both tokens SHALL provide adequate contrast against their respective background surfaces in both light and dark modes.

#### Scenario: Primary text readability in light mode
- **WHEN** primary text renders on a light neumorphic surface
- **THEN** the text color provides clear visual contrast against the warm off-white background

#### Scenario: Secondary text readability in dark mode
- **WHEN** secondary text (timestamps, source app) renders on a dark neumorphic card
- **THEN** the text is legible with reduced but sufficient contrast relative to primary text

### Requirement: Reusable neumorphic view modifiers
The system SHALL provide SwiftUI view modifiers for neumorphic effects: one for extruded/raised surfaces and one for inset/recessed surfaces. These modifiers SHALL read shadow colors and offsets from the active theme tokens so that all neumorphic elements adapt automatically when the theme changes.

#### Scenario: Extruded modifier applied to a view
- **WHEN** the `.neuExtruded()` modifier is applied to a view
- **THEN** the view renders with dual outer shadows (light top-left, dark bottom-right) using the current theme's shadow tokens

#### Scenario: Inset modifier applied to a view
- **WHEN** the `.neuInset()` modifier is applied to a view
- **THEN** the view renders with dual inner shadows (dark top-left, light bottom-right) using the current theme's shadow tokens

#### Scenario: Modifiers react to theme change
- **WHEN** the theme changes from dark to light
- **THEN** all views using neumorphic modifiers update their shadow colors to match the new theme without requiring manual intervention
