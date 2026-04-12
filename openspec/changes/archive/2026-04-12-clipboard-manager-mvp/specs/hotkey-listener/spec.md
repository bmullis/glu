## ADDED Requirements

### Requirement: Global hotkey registration
The system SHALL register Cmd+Shift+V as a system-wide global hotkey using the HotKey Swift package. The hotkey SHALL work regardless of which application is in the foreground.

#### Scenario: Hotkey pressed while in another app
- **WHEN** the user presses Cmd+Shift+V while typing in Safari
- **THEN** the Glu panel SHALL appear at the bottom of the active screen

### Requirement: Toggle behavior
The global hotkey SHALL toggle the panel visibility. Pressing the hotkey when the panel is visible SHALL dismiss it.

#### Scenario: Panel already visible
- **WHEN** the panel is visible and the user presses Cmd+Shift+V
- **THEN** the panel SHALL be dismissed

### Requirement: Escape key dismissal
The system SHALL dismiss the panel when the user presses the Escape key while the panel is visible.

#### Scenario: Escape pressed with panel open
- **WHEN** the panel is visible and the user presses Escape
- **THEN** the panel SHALL be dismissed and focus SHALL return to the previously active application

### Requirement: Accessibility permission handling
The system SHALL detect whether Accessibility permissions have been granted. If not granted, the system SHALL present a prompt guiding the user to System Settings > Privacy & Security > Accessibility.

#### Scenario: First launch without permissions
- **WHEN** the app launches for the first time and Accessibility access is not granted
- **THEN** the system SHALL display an onboarding dialog explaining the required permission and offer a button to open the relevant System Settings pane
