## ADDED Requirements

### Requirement: Bottom-anchored floating panel
The system SHALL display an NSPanel anchored to the bottom of the active screen (`NSScreen.main`), spanning the full screen width. The panel SHALL use a non-activating style so the foreground application does not lose focus. The panel height SHALL be fixed at 200 points.

#### Scenario: Panel invoked
- **WHEN** the user triggers the global hotkey
- **THEN** a translucent panel SHALL slide up from the bottom of the active screen, spanning full width with a fixed height of 200 points

#### Scenario: Panel on active monitor
- **WHEN** the user triggers the hotkey while working on a secondary monitor
- **THEN** the panel SHALL appear on the screen containing the currently focused window, not the primary display

### Requirement: Empty state
When there are no clipboard entries in history, the panel SHALL display a placeholder message.

#### Scenario: No history available
- **WHEN** the user triggers the hotkey and the clipboard history is empty
- **THEN** the panel SHALL display a centered placeholder message such as "Nothing copied yet"

### Requirement: Horizontal scrolling card layout
The panel SHALL display clipboard history as horizontally scrollable cards, each approximately 300 points wide. Each card SHALL show a preview of the clipboard content appropriate to its type, with 4-5 lines of text preview.

#### Scenario: Text entry preview
- **WHEN** the panel displays a text clipboard entry
- **THEN** the card SHALL show a truncated text preview (first 4-5 lines) using proportional font for prose and monospace font for detected code

#### Scenario: Code detection for font selection
- **WHEN** the panel displays a text entry containing code indicators (consistent indentation, braces/brackets, semicolons, keywords like `func`, `def`, `const`, `import`, `=>`, `->`)
- **THEN** the card SHALL render the preview in monospace font

#### Scenario: Image entry preview
- **WHEN** the panel displays an image clipboard entry
- **THEN** the card SHALL show a scaled thumbnail of the image

#### Scenario: File entry preview
- **WHEN** the panel displays a file clipboard entry
- **THEN** the card SHALL show the file icon and filename

#### Scenario: URL entry preview
- **WHEN** the panel displays a URL clipboard entry
- **THEN** the card SHALL show the URL string with a link icon

### Requirement: Search and filtering
The panel SHALL include a search/filter bar that filters clipboard history cards in real-time as the user types. Search SHALL match against text content for text/URL entries, filenames for file entries, the keyword "image" for image entries, and source application name when available.

#### Scenario: Text search
- **WHEN** the user types "TODO" in the search bar
- **THEN** only clipboard entries containing "TODO" in their text content SHALL be displayed

#### Scenario: File search by name
- **WHEN** the user types "readme" in the search bar
- **THEN** file entries with "readme" in the filename SHALL be displayed

#### Scenario: Image search
- **WHEN** the user types "image" in the search bar
- **THEN** all image clipboard entries SHALL be displayed

#### Scenario: Search cleared
- **WHEN** the user clears the search bar
- **THEN** all clipboard entries SHALL be displayed again

### Requirement: Card selection
The user SHALL be able to select a card by clicking on it. Clicking a card SHALL trigger the paste action.

#### Scenario: Card clicked
- **WHEN** the user clicks on a clipboard history card
- **THEN** the paste action SHALL be triggered for that card

### Requirement: Context menu on cards
The user SHALL be able to right-click a card to access a context menu with a "Delete" option.

#### Scenario: Right-click delete
- **WHEN** the user right-clicks a clipboard card and selects "Delete"
- **THEN** the entry SHALL be deleted from history and the card SHALL be removed from the panel

### Requirement: Keyboard navigation
The user SHALL be able to navigate between cards using the left and right arrow keys, and select a card by pressing Enter/Return.

#### Scenario: Arrow key navigation
- **WHEN** the panel is visible and the user presses the right arrow key
- **THEN** the selection SHALL move to the next card to the right

#### Scenario: Enter to paste
- **WHEN** a card is selected and the user presses Enter
- **THEN** the paste action SHALL be triggered for the selected card

### Requirement: Click-outside dismissal
The panel SHALL be dismissed when the user clicks outside of it (on any other window or the desktop).

#### Scenario: Click outside panel
- **WHEN** the panel is visible and the user clicks on their editor window
- **THEN** the panel SHALL be dismissed

### Requirement: Slide animation
The panel SHALL animate in (slide up) and out (slide down) with a smooth animation lasting approximately 0.2 seconds.

#### Scenario: Panel appears
- **WHEN** the panel is triggered to appear
- **THEN** it SHALL slide up from below the screen edge over 0.2 seconds

#### Scenario: Panel dismissed
- **WHEN** the panel is dismissed
- **THEN** it SHALL slide down below the screen edge over 0.2 seconds
