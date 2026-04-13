## ADDED Requirements

### Requirement: Theme modes
The system SHALL support three theme modes: light, dark, and system. When set to system, the resolved appearance SHALL match the current macOS system appearance setting.

#### Scenario: User selects dark mode
- **WHEN** the user selects dark mode via the theme toggle
- **THEN** all UI surfaces immediately render using dark theme tokens

#### Scenario: User selects light mode
- **WHEN** the user selects light mode via the theme toggle
- **THEN** all UI surfaces immediately render using light theme tokens

#### Scenario: System mode follows macOS appearance
- **WHEN** the user selects system mode and macOS is set to dark appearance
- **THEN** the app renders using dark theme tokens
- **WHEN** the macOS appearance changes to light while system mode is active
- **THEN** the app reactively updates to render using light theme tokens

### Requirement: Theme persistence
The system SHALL persist the user's selected theme mode across application launches. On first launch with no stored preference, the system SHALL default to system mode.

#### Scenario: Theme preference survives relaunch
- **WHEN** the user selects light mode and quits the app
- **THEN** on next launch, the app renders in light mode without user interaction

#### Scenario: First launch defaults to system
- **WHEN** the app launches for the first time with no stored preference
- **THEN** the active theme mode SHALL be system

### Requirement: Design token system
The system SHALL provide a centralized set of design tokens consumed by all views. Tokens SHALL include at minimum: primary background, card background, surface highlight, surface shadow, text primary, text secondary, text tertiary, accent color, search bar background, divider color, neumorphic light shadow color, and neumorphic dark shadow color.

#### Scenario: Tokens resolve differently per theme
- **WHEN** the active theme is dark
- **THEN** the card background token resolves to a dark surface color
- **WHEN** the active theme is light
- **THEN** the card background token resolves to a light surface color

#### Scenario: All views use tokens
- **WHEN** any view renders a styled surface
- **THEN** it SHALL read colors and shadows from the theme token system, not from hardcoded values

### Requirement: Theme toggle control
The system SHALL display a theme toggle button in the panel toolbar area. The button SHALL display an SF Symbol icon reflecting the current active mode: sun for light, moon for dark, and a half-circle for system. Tapping the button SHALL cycle through the modes in order: system, light, dark.

#### Scenario: Toggle cycles through modes
- **WHEN** the current mode is system and the user taps the toggle
- **THEN** the mode changes to light
- **WHEN** the current mode is light and the user taps the toggle
- **THEN** the mode changes to dark
- **WHEN** the current mode is dark and the user taps the toggle
- **THEN** the mode changes to system

#### Scenario: Toggle icon reflects active mode
- **WHEN** the active mode is light
- **THEN** the toggle displays a sun icon
- **WHEN** the active mode is dark
- **THEN** the toggle displays a moon icon
- **WHEN** the active mode is system
- **THEN** the toggle displays a half-circle icon
